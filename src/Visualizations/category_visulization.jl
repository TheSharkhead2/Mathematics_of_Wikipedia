using JLD2
using Graphs
using Plots
using Cairo, Fontconfig
using GraphPlot, Compose

# Currently working on implementing julia script to visualize the categories data
# The data is stored in a JLD2 file, which is a julia specific file format

function basicvis(path::String)
    # Load the data from the JLD2 file
    categories_path = "data/categories.jld2"
    (categories_to_pages, category_to_id, category_graph) = JLD2.load_object(categories_path)

    # Using Graphs to plot and save the graph
    save_path = path

    category_names = [category for (category, _) in category_to_id] # list of category names by node
    node_size = [v*10e20 for v in degree(category_graph)] # nodes size proportional to their degree
    draw(PDF(save_path, 30cm, 30cm), gplot(category_graph, nodesize=node_size, arrowlengthfrac = 0))

end # function main
