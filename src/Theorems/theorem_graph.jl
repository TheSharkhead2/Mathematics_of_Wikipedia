using Graphs
using JLD2

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

main()

# more to come ... 

