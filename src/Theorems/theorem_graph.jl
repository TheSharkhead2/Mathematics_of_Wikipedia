using Graphs
using JLD2
using DataFrames, CSV

using WikipediaStructure.Categories

function main()
    path_name = "Data/theorems.jld2"
    pages_path = "Data/pages.jld2"

    j = load_object(pages_path)
    graph, labels, categories = load_object(path_name)

    # Get original ids to label dictionary from our pages graph
    id_to_label = Dict{Int64, String}()
    for x in j[1]
        id_to_label[x[2]] = x[1]
    end

    # Get new id to label vector for theorems graph
    new_id_to_label = Dict{Int64, String}()
    for (new_id, original_id) in enumerate(labels)
        new_id_to_label[new_id] = id_to_label[original_id]
    end
end

function graph_to_edges_csv(g::AbstractGraph, output_path; id_to_label::Dict=Dict())
    # choice
    if length(id_to_label) > 0
        edge_list = DataFrame(src = String[], dst = String[])
    else 
        edge_list = DataFrame(src = Int[], dst = Int[])
    end
    for e in edges(g)
        if length(id_to_label) > 0
            push!(edge_list, (src = id_to_label[e.src], dst = id_to_label[e.dst]))
        else
            push!(edge_list, (src = e.src, dst = e.dst))
        end
    end
    # save
    CSV.write(output_path, edge_list)
end

function subgraph_to_edges_csv(base_cat::String, categories_path::String, pages_path::String, output_path::String; depth::Int64=2)
    (sgraph, vmap, field_pages_new_ids) = get_subgraph_with_category_labeling(base_cat, categories_path, pages_path, depth)

    j = load_object(pages_path)

    # Get original ids to label dictionary from our pages graph
    id_to_label = Dict{Int64, String}()
    for x in j[1]
        id_to_label[x[2]] = x[1]
    end

    # Get new id to label vector for s graph
    new_id_to_label = Dict{Int64, String}()
    for (new_id, original_id) in enumerate(vmap)
        new_id_to_label[new_id] = id_to_label[original_id]
    end
    graph_to_edges_csv(sgraph, output_path, id_to_label=new_id_to_label)

end
# more to come ... 

