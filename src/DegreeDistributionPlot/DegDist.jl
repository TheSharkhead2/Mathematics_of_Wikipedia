using Graphs
using Plots

function plot_degree_dist(g::AbstractGraph; degfn::Function=degree, bucketSize::Int=1)
    # Get the degree histogram using the Graphs degree function
    if degfn == indegree
        degrees = indegree(g)
    else 
        degrees = outdegree(g)
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
    valid_indices = (frequencies .> 0) .& (degrees .> 0)
    plot_degrees = degrees[valid_indices]
    plot_frequencies = frequencies[valid_indices]
    # Create plot
    p = scatter(plot_degrees, plot_frequencies, 
        title = degfn == indegree ? "In-Degree Distribution" : 
                degfn == outdegree ? "Out-Degree Distribution" : " ",
        xlabel = "Degree", ylabel = "Number of Vertices",
        legend = false, markershape = :circle,
        markersize = 5, markerstrokewidth = 2,
        xscale=:log10, yscale=:log10,
        color = :purple,
    )
    return p
end
