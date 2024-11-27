using JLD2
using Graphs
using GraphPlot, Compose
using Plots, GraphRecipes
using GLMakie, GraphMakie, SGtSNEpi, SNAPDatasets
using Karnak, NetworkLayout, Colors

using Graphs
using JLD2

# Currently working on implementing julia script to visualize the categories data
# The data is stored in a JLD2 file, which is a julia specific file format

# Load the data from the JLD2 file
categories_path = "data/categories.jld2"
data = JLD2.load(category_path)
(categories_to_pages, category_to_id, category_graph) = JLD2.load_object(categories_path)

