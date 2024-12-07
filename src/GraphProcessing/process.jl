using Graphs, Plots
using JLD2
using DataFrames, CSV
using SGtSNEpi, Random, Distributions
using CairoMakie, Colors, LinearAlgebra
using Revise
using WikipediaStructure
using GLMakie

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

"""
plot_degree_dist(g, degfn, bucketSize)

Takes in a graph, degreefunction (degree, indegree, or outdegree), and bucketSize
Plots the degree distribution of the graph on a log-log plot 
"""
function plot_degree_dist(g::AbstractGraph; degfn::Function=degree, bucketSize::Int=1)
    # Get the degree histogram using the Graphs degree function
    if degfn == indegree
        degrees = indegree(g)
    elseif degfn == outdegree
        degrees = outdegree(g)
    else 
        degrees = degree(g)
    end
    # Count the frequency of each degree
    hist = Dict{Int, Int}()
    for d in degrees
        bucket = div(d, bucketSize) * bucketSize  # Calculate the bucket for the degree
        hist[bucket] = get(hist, bucket, 0) + 1
    end
    # Convert dictionary to sorted arrays for plotting
    degreeBuckets = sort(collect(keys(hist))) 
    frequencies = [hist[d] for d in degreeBuckets]
    # Filter out zeros and any degrees <= 0 for log plot
    valid_indices = (frequencies .> 0) .& (degreeBuckets .> 0)
    plot_degrees = degreeBuckets[valid_indices]
    plot_frequencies = frequencies[valid_indices]
    # Create plot
    p = Plots.scatter(plot_degrees, plot_frequencies, 
        title = degfn == indegree ? "In-Degree Distribution" : 
                degfn == outdegree ? "Out-Degree Distribution" : "Degree Distribution",
        xlabel = "Degree", ylabel = "Number of Vertices",
        legend = false, markershape = :circle,
        markersize = 5, markerstrokewidth = 2,
        xscale=:log10, yscale=:log10,
        color = :purple,
    )
    return p
end


# x = show_embedding( Y, node_labels ; A = adjacency_matrix(sg), res = (2000, 2000), mrk_size=10,lwd_in=0.9,lwd_out = 0.5)
function plot_communities(sg::AbstractGraph, labeling; output_path::String="", mrk_size=10, lwd_in=0.05, lwd_out = 0.01, max_iter = 5000) # add graph customization parameters like lwd and mrk_size...
    # make sure it is undirected
    sg = Graph(sg)
    
    Random.seed!(0);
    Y0 = rand(Normal(0,10), (size(adjacency_matrix(sg),1), 2) );

    Y = sgtsnepi(adjacency_matrix(SimpleGraph(sg)); Y0 = Y0, λ=100, max_iter=max_iter, version=SGtSNEpi.NUCONV, early_exag=500, alpha=10, eta=20, np=10);
    # max iter low for testing
    set_theme!(theme_black())

    x = show_embedding( Y, labeling ; A = adjacency_matrix((sg)), res = (2000, 2000), lwd_in = lwd_in, lwd_out = lwd_out, edge_alpha=0.9, mrk_size=mrk_size)

    hidedecorations!(x.content[1]) # removes axis labels and whatnot`
    hidespines!(x.content[1]) # fully removes axis
    if length(output_path) > 0
        save(output_path, x)
    end
end