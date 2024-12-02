using Graphs
using LinearAlgebra

import JLD2

using WikipediaStructure.Categories

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

    return subgraph    
end # function community_detection_in_subgraph
