using Graphs
using JLD2
using DataFrames, CSV

function graph_id_to_label()
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

    # max, id = findmax(deg_cent)
    # new_id_to_label[id]

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


# more to come ... 

