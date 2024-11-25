using LinearAlgebra
using Graphs
using SparseArrays

import JLD2

function mathematics_fields_categories(categories_path::String, pages_path::String, depth::Int64)
    FIELDS_OF_MATHEMATICS::String = "Category:Fields of mathematics"

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
        category_to_id[FIELDS_OF_MATHEMATICS]
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

    all_pages_nonunique = Vector{Int64}()

    field_pages_by_id
end # function mathematical_categories

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
