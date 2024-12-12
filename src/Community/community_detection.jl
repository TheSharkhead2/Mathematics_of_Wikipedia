using Graphs
using LinearAlgebra
using SparseArrays
using ProgressMeter
using StatsBase

import JLD2

using WikipediaStructure.Categories
using WikipediaStructure.Visualizations

# somewhat blatantly taken from: https://raw.githubusercontent.com/jamiehadd/Math189AD-MathematicalDataScienceAndTopicModeling/main/code/sym_mult_ups.py
function sym_nmf_multiplicative_updates(A, k::Int64; α=1, M=1000)
    EPSILON_DIVIDE = 1e-6
    (N, _) = size(A)

    W = rand(N, k)
    H = rand(k, N)

    progress_bar = Progress(M)
    for i in 1:M
        Abar = vcat(A, sqrt(α) .* transpose(W))
        Wbar = vcat(W, sqrt(α) .* I(k))

        H = H .* ((transpose(Wbar) * Abar) ./ (transpose(Wbar) * Wbar * H .+ EPSILON_DIVIDE))

        W = transpose(H)

        # error = norm(A - transpose(H)*H)

        # next!(progress_bar; showvalues=[("Error", error)])
        next!(progress_bar)
    end # for i

    return transpose(H)
end # function sym_nmf_multiplicative_updates

struct CommunityDetectionResult
    # induced subgraph 
    subgraph::SimpleDiGraph

    # graph embedding
    Y::Matrix{Float64}

    # vmap where `subgraph_vmap[i]` is the original id for the ith node in the subgraph
    subgraph_vmap::Vector{Int64}

    # names for each node in subgraph (original page name)
    page_names::Vector{String}

    # Implicit communities from category graph
    implicit_labels::Vector{Int64}

    # category ids for the implicit categories
    implicit_category_ids::Vector{Int64} 

    # category names for implicit categories
    implicit_category_names::Vector{String} 

    # found communities (via specified community detection method)
    found_labels::Vector{Int64}

    # for each found community, the count of how many of each of the implicit 
    # categories appeared in the community's nodes. NOTE: will count +1 
    # for all implicit categories assigned for a node, hence the counts
    # will sum to move than nv(G)
    found_communities_implicit_category_counts::Vector{Vector{Int64}}

    # page id lists for each community, ranked by centrality measure
    ranked_found_community_page_ids::Vector{Vector{Int64}}

    # page name list for each community, ranked by centrality measure
    ranked_found_community_page_names::Vector{Vector{String}}
end # struct CommunityDetectionResult

function community_detection_in_subgraph(
    pages::String,
    categories::String,
    subgraph_parent_category::String,
    subgraph_depth::Int64,
    communities::Union{Int64, Nothing}; 
    remove_isolated_nodes::Bool = true,
    centrality_measure = pagerank, # centrality measure to use when ranking nodes
    community_detection_method = :symnmf, # :symnmf
    community_detection_max_iter = 1000,
    graph_embedding_lambda = 100.,
    graph_embedding_alpha = 10,
    graph_embedding_eta = 20,
    graph_embedding_max_iter = 5000,
    graph_embedding_early_exag = 500,
    graph_embedding_np = 0,
    graph_embedding_seed = 42,
)
    community_detection_method ∉ [:symnmf] && throw(ArgumentError("Community detection method $community_detection_method not yet supported. Please use one of: [:symnmf]"))
    (community_detection_method == :symnmf && isnothing(communities)) && throw(ArgumentError("For community detection method $community_detection_method you must specify a number of communities to find."))
    (community_detection_method == :symnmf && communities <= 0) && throw(ArgumentError("Number of communities to find must be positive. You passed $communities."))

    (
        page_to_id,
        page_to_categories,
        page_graph
    ) = JLD2.load_object(pages)

    (
        categories_to_pages,
        category_to_id,
        category_graph
    ) = JLD2.load_object(categories)

    id_to_category = Dict{Int64, String}()
    for x in category_to_id
        id_to_category[x[2]] = x[1]
    end # for x

    id_to_page = Dict{Int64, String}()
    for x in page_to_id
        id_to_page[x[2]] = x[1]
    end # for x

    (
        subgraph,
        sg_vmap,
        actual_subgraph_categories,
        subgraph_category_labels
    ) = get_subgraph_with_category_labeling(
        subgraph_parent_category,
        categories,
        pages,
        subgraph_depth
    )    

    # get all categories that each node in subgraph could be placed into
    subgraph_implicit_category_labeling_all = Dict{Int64, Vector{Int64}}()
    for (cat_id, cat) in enumerate(actual_subgraph_categories)
        for page_id in cat 
            # if the page hasn't been seen yet
            if isnothing(get(subgraph_implicit_category_labeling_all, page_id, nothing))
                subgraph_implicit_category_labeling_all[page_id] = Int64[cat_id]
            else # otherwise, add the second category label
                push!(subgraph_implicit_category_labeling_all[page_id], cat_id)
            end # if
        end # for page_id
    end # for (cat_id, cat)

    # for now create a "proper" labeling by randomly selecting a category for each node
    # TODO: for the future, maybe weight this based on the depth at which this page was pulled from?
    subgraph_implicit_labeling = Dict{Int64, Int64}()
    for (page_id, cat_id_vec) in subgraph_implicit_category_labeling_all
        subgraph_implicit_labeling[page_id] = sample(cat_id_vec) # randomly pick a category label 
    end # for (page_id, cat_id_vec)

    # we want a vector rather than a dict for the category labeling 
    subgraph_labels_vec = Vector{Int64}()
    for page_id in 1:max(keys(subgraph_implicit_labeling)...) # WLOG should have all page_ids in this range
        push!(subgraph_labels_vec, subgraph_implicit_labeling[page_id])
    end # for page_id

    # remove isolated nodes
    connected_subgraph_vmap = collect(1:nv(subgraph)) # start with identity vmap
    if remove_isolated_nodes
        # get largest connected component 
        sg_connected_components = connected_components(subgraph)
        largest_cc_idx = findmax(length.(sg_connected_components))[2]

        connected_subgraph, connected_subgraph_vmap = induced_subgraph(subgraph, sg_connected_components[largest_cc_idx])

        # construct vmap back to original pages graph
        connected_subgraph_vmap_to_pages = Vector{Int64}()
        for sg_page_id in connected_subgraph_vmap
            push!(connected_subgraph_vmap_to_pages, sg_vmap[sg_page_id])
        end # for sg_page_id

        # also get the labels for the new subgraph
        connected_subgraph_labels_vec = Vector{Int64}()
        for sg_page_id in 1:nv(connected_subgraph)
            push!(connected_subgraph_labels_vec, subgraph_labels_vec[connected_subgraph_vmap[sg_page_id]])
        end # for sg_page_id

        subgraph = connected_subgraph
        sg_vmap = connected_subgraph_vmap_to_pages
        subgraph_labels_vec = connected_subgraph_labels_vec
    end # if

    # get name for each implicit category (just parent category name)
    subgraph_category_labels_names = Vector{String}()
    for cat_id in subgraph_category_labels
        # add name of each category to "name" each implicit category
        push!(
            subgraph_category_labels_names,
            id_to_category[cat_id]
        )
    end # for cat_id

    # get names for each page
    subgraph_page_names = Vector{String}()
    for sg_page_id in 1:nv(subgraph)
        push!(subgraph_page_names,
            id_to_page[sg_vmap[sg_page_id]]
        )
    end # for sg_page_id

    found_community_labeling = Vector{Int64}()
    if community_detection_method == :symnmf
        @info "Running SymNMF community detection..."
        # run SymNMF for community detection
        H = sym_nmf_multiplicative_updates(
            adjacency_matrix(SimpleGraph(subgraph)),
            communities;
            M = community_detection_max_iter
        )

        # find maximum entry in each row (which is the found community for that node)
        H_max_entries = findmax(H; dims=2)

        # pull out max indices to get labeling
        found_community_labeling = [
            H_max_entries[2][i][2] for i in 1:size(H)[1]
        ]
    end # if

    # TODO: need to set `communities` for community detection algorithms that don't have defined community count

    # get mapping from found community id to contained pages
    found_communities_to_node_ids = [Int64[] for _ in 1:communities]
    for (page_id, page_community_id) in enumerate(found_community_labeling)
        push!(
            found_communities_to_node_ids[page_community_id],
            page_id
        )
    end # for (page_id, page_community_id)

    # for each found community, count the occurences of each category in implicit labeling
    found_communities_implicit_category_counts = [
        [0 for _ in 1:length(subgraph_category_labels)]
        for _ in 1:communities 
    ]
    for (community_id, community_pages) in enumerate(found_communities_to_node_ids)
        for page_id in community_pages
            # get the labeling for this page from the implicit subgraph labeling
            page_subgraph_labeling = subgraph_implicit_category_labeling_all[connected_subgraph_vmap[page_id]]

            # count appearances
            for implicit_cat in page_subgraph_labeling
                found_communities_implicit_category_counts[community_id][implicit_cat] += 1
            end # for implicit_cat
        end # for page_id
    end # for (community_id, community_pages)

    subgraph_centrality = centrality_measure(subgraph)
 
    # sort found community pages by centrality measure
    found_communities_pages_ranked = [
        sort(
            found_communities_to_node_ids[i],
            by=x->subgraph_centrality[x],
            rev=true # want highest first
        ) for i in 1:communities
    ]

    # turn the ids in ranking into page names 
    found_communities_pages_ranked_names = [
        [subgraph_page_names[
            found_communities_pages_ranked[community_id][i]
        ] for i in eachindex(found_communities_pages_ranked[community_id])]
        for community_id in 1:communities
    ]
    
    @info "Performing graph embedding for visualization..."
    Y = perform_graph_embedding(
        subgraph;
        lambda = graph_embedding_lambda,
        alpha = graph_embedding_alpha,
        eta = graph_embedding_eta,
        max_iter = graph_embedding_max_iter,
        early_exag = graph_embedding_early_exag,
        np = graph_embedding_np,
        seed = graph_embedding_seed,
    )

    return CommunityDetectionResult(
        subgraph,
        Y,
        sg_vmap,
        subgraph_page_names,
        subgraph_labels_vec,
        subgraph_category_labels,
        subgraph_category_labels_names,
        found_community_labeling,
        found_communities_implicit_category_counts,
        found_communities_pages_ranked,
        found_communities_pages_ranked_names
    )
end # function community_detection_in_subgraph

function community_detection_in_subgraph(
    pages::String,
    categories::String,
    subgraph_nodes::Vector{Int64},
    communities::Union{Int64, Nothing}; 
    remove_isolated_nodes::Bool = true,
    centrality_measure = pagerank, # centrality measure to use when ranking nodes
    community_detection_method = :symnmf, # :symnmf
    community_detection_max_iter = 1000,
    graph_embedding_lambda = 100.,
    graph_embedding_alpha = 10,
    graph_embedding_eta = 20,
    graph_embedding_max_iter = 5000,
    graph_embedding_early_exag = 500,
    graph_embedding_np = 0,
    graph_embedding_seed = 42,
)
    community_detection_method ∉ [:symnmf] && throw(ArgumentError("Community detection method $community_detection_method not yet supported. Please use one of: [:symnmf]"))
    (community_detection_method == :symnmf && isnothing(communities)) && throw(ArgumentError("For community detection method $community_detection_method you must specify a number of communities to find."))
    (community_detection_method == :symnmf && communities <= 0) && throw(ArgumentError("Number of communities to find must be positive. You passed $communities."))

    (
        page_to_id,
        page_to_categories,
        page_graph
    ) = JLD2.load_object(pages)

    (
        categories_to_pages,
        category_to_id,
        category_graph
    ) = JLD2.load_object(categories)

    id_to_category = Dict{Int64, String}()
    for x in category_to_id
        id_to_category[x[2]] = x[1]
    end # for x

    id_to_page = Dict{Int64, String}()
    for x in page_to_id
        id_to_page[x[2]] = x[1]
    end # for x

    subgraph, sg_vmap = induced_subgraph(page_graph, subgraph_nodes)

    # remove isolated nodes
    connected_subgraph_vmap = collect(1:nv(subgraph)) # start with identity vmap
    if remove_isolated_nodes
        # get largest connected component 
        sg_connected_components = connected_components(subgraph)
        largest_cc_idx = findmax(length.(sg_connected_components))[2]

        connected_subgraph, connected_subgraph_vmap = induced_subgraph(subgraph, sg_connected_components[largest_cc_idx])

        # construct vmap back to original pages graph
        connected_subgraph_vmap_to_pages = Vector{Int64}()
        for sg_page_id in connected_subgraph_vmap
            push!(connected_subgraph_vmap_to_pages, sg_vmap[sg_page_id])
        end # for sg_page_id

        subgraph = connected_subgraph
        sg_vmap = connected_subgraph_vmap_to_pages
    end # if

    # get names for each page
    subgraph_page_names = Vector{String}()
    for sg_page_id in 1:nv(subgraph)
        push!(subgraph_page_names,
            id_to_page[sg_vmap[sg_page_id]]
        )
    end # for sg_page_id

    found_community_labeling = Vector{Int64}()
    if community_detection_method == :symnmf
        @info "Running SymNMF community detection..."
        # run SymNMF for community detection
        H = sym_nmf_multiplicative_updates(
            adjacency_matrix(SimpleGraph(subgraph)),
            communities;
            M = community_detection_max_iter
        )

        # find maximum entry in each row (which is the found community for that node)
        H_max_entries = findmax(H; dims=2)

        # pull out max indices to get labeling
        found_community_labeling = [
            H_max_entries[2][i][2] for i in 1:size(H)[1]
        ]
    end # if

    # TODO: need to set `communities` for community detection algorithms that don't have defined community count

    # get mapping from found community id to contained pages
    found_communities_to_node_ids = [Int64[] for _ in 1:communities]
    for (page_id, page_community_id) in enumerate(found_community_labeling)
        push!(
            found_communities_to_node_ids[page_community_id],
            page_id
        )
    end # for (page_id, page_community_id)

    subgraph_centrality = centrality_measure(subgraph)
 
    # sort found community pages by centrality measure
    found_communities_pages_ranked = [
        sort(
            found_communities_to_node_ids[i],
            by=x->subgraph_centrality[x],
            rev=true # want highest first
        ) for i in 1:communities
    ]

    # turn the ids in ranking into page names 
    found_communities_pages_ranked_names = [
        [subgraph_page_names[
            found_communities_pages_ranked[community_id][i]
        ] for i in eachindex(found_communities_pages_ranked[community_id])]
        for community_id in 1:communities
    ]
    
    @info "Performing graph embedding for visualization..."
    Y = perform_graph_embedding(
        subgraph;
        lambda = graph_embedding_lambda,
        alpha = graph_embedding_alpha,
        eta = graph_embedding_eta,
        max_iter = graph_embedding_max_iter,
        early_exag = graph_embedding_early_exag,
        np = graph_embedding_np,
        seed = graph_embedding_seed,
    )

    return CommunityDetectionResult(
        subgraph,
        Y,
        sg_vmap,
        subgraph_page_names,
        Vector{Int64}(),
        Vector{Int64}(),
        Vector{String}(),
        found_community_labeling,
        Vector{Vector{Int64}}(),
        found_communities_pages_ranked,
        found_communities_pages_ranked_names
    )
end # function community_detection_in_subgraph
