using Graphs
using LinearAlgebra
using SparseArrays
using ProgressMeter

import JLD2

using WikipediaStructure.Categories

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

function community_detection_in_subgraph(
    pages::String,
    categories::String,
    subgraph_parent_category::String,
    subgraph_depth::Int64
)
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

    subgraph_category_labels = outneighbors(
        category_graph,
        category_to_id[subgraph_parent_category]
    )

    println(length(subgraph_category_labels))

    (
        subgraph,
        sg_vmap,
        actual_subgraph_categories
    ) = get_subgraph_with_category_labeling(
        subgraph_parent_category,
        categories,
        pages,
        subgraph_depth
    )    

    return (subgraph, actual_subgraph_categories)
end # function community_detection_in_subgraph
