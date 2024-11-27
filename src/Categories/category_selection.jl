using LinearAlgebra
using Graphs
using SparseArrays

import JLD2

"""
    get_subgraph_with_category_labeling(base_cat, categories_path, pages_path, depth)

Takes in `base_cat` and creates the induced subgraph searching at `depth`
recursively through the sub-categories of `base_cat`. Will return the induced
subgraph, the vertex map (where the ith index is the old id for the ith node 
in the subgraph), and the category labeling of each sub-category of `base_cat`
to the new vertex ids.
Note `categories_path` is the path to the large categories graph and
`pages_path` is the path to the whole graph.
"""
function get_subgraph_with_category_labeling(base_cat::String, categories_path::String, pages_path::String, depth::Int64)

    (page_to_id, page_to_categories, page_graph) = JLD2.load_object(pages_path)

    (categories_to_pages, category_to_id, category_graph) = JLD2.load_object(categories_path)

    id_to_category = Dict{Int64, String}()
    for x in category_to_id
        id_to_category[x[2]] = x[1]
    end # for x

    id_to_page = Dict{Int64, String}()
    for x in page_to_id
        id_to_page[x[2]] = x[1]
    end # for x
    
    # get "all" mathematics fields and treat them as categories
    field_category_ids = outneighbors(
        category_graph,
        category_to_id[base_cat]
    )

    field_sub_categories = Vector{Vector{Int64}}()

    for category_id in field_category_ids
        sub_categories = Vector{Int64}()
        recurse_category_graph!(
            sub_categories,
            category_id,
            category_graph,
            depth
        )

        push!(field_sub_categories, unique(sub_categories))
    end # for category_id

    field_pages = Vector{Vector{String}}()

    for field in field_sub_categories
        sub_field_pages = Vector{String}()
        for subcat in field 
            append!(sub_field_pages, categories_to_pages[id_to_category[subcat]])
        end # for subcat

        push!(field_pages, unique(sub_field_pages))
    end # for field

    field_pages_by_id = Vector{Vector{Int64}}()
    for field in field_pages
        field_page_ids = map(x->page_to_id[x], field)

        push!(field_pages_by_id, field_page_ids)
    end # for field

    all_pages_unique_set = Set{Int64}()

    for field_pages in field_pages_by_id
        for page in field_pages
            push!(all_pages_unique_set, page)
        end # for page
    end # for field_pages

    sgraph, vmap = induced_subgraph(page_graph, collect(all_pages_unique_set))

    # convert page ids from original ids to new ids
    field_pages_new_ids = Vector{Vector{Int64}}()
    for field_page_ids in field_pages_by_id
        field_page_new = Vector{Int64}() # new ids
        for field_page in field_page_ids 
            # add the new graph id 
            push!(field_page_new, findall(x->x==field_page, vmap)[1])
        end # for field_page

        push!(field_pages_new_ids, field_page_new)
    end # for field_page_ids

    (sgraph, vmap, field_pages_new_ids)
end # function get_subgraph_with_category_labeling

function recurse_category_graph!(
    sub_categories::Vector{Int64},
    category_id::Int64,
    G::SimpleDiGraph,
    depth::Int64
)
    if depth == 0
        return
    end # if 

    sub_category_neighbors = outneighbors(
        G,
        category_id
    )

    append!(sub_categories, sub_category_neighbors)

    for cat_id in sub_category_neighbors
        recurse_category_graph!(
            sub_categories,
            cat_id,
            G,
            depth-1
        )
    end # for cat_id
end # function recurse_category_graph!
