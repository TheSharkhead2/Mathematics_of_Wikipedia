using JLD2
using Graphs
using Plots
using GraphPlot, Compose
using Cairo, Fontconfig

# Currently working on implementing julia script to visualize the categories data
# The data is stored in a JLD2 file, which is a julia specific file format

function main()
    # Load the data from the JLD2 file
    categories_path = "data/categories.jld2"
    data = JLD2.load(categories_path)
    (categories_to_pages, category_to_id, category_graph) = JLD2.load_object(categories_path)

    # Using Graphs to plot and save the graph
    save_path = "/Users/christianjohnson/Downloads/MATH189_Project/src/Visualizations/output/categories.pdf"
    draw(PDF(save_path, 16cm, 16cm),gplot(category_graph))

end # function main

main()  