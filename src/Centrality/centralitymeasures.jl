using JLD2
using Graphs
using Plots
using Cairo, Fontconfig
using GraphPlot, Compose


function analyze(path::String)

    categories_path = "data/categories.jld2"
    (categories_to_pages, category_to_id, category_graph) = JLD2.load_object(categories_path)

    # Convert to undirected graph for centrality analysis
    undirected_graph = SimpleGraph(category_graph)

    # Compute centrality measures
    degree_centrality = degree_centrality_measure(undirected_graph)
    betweenness_centrality = betweenness_centrality_measure(undirected_graph)
end


# Helper functions for centrality measures
function betweenness_centrality_measure(g::Graph)
    n = nv(g)
    bc = zeros(Float64, n)
    for s in 1:n
        dijkstra = dijkstra_shortest_paths(g, s)
        shortest_paths = all_shortest_paths(dijkstra)
        sp_counts = zeros(Int, n)
        for path in shortest_paths
            for v in path[2:end-1]  # Exclude source and target
                sp_counts[v] += 1
            end
        end
        bc .+= sp_counts
    end
    return bc / sum(bc)
end

function closeness_centrality_measure(g::Graph)
    n = nv(g)
    cc = zeros(Float64, n)
    for v in 1:n
        sp_lengths = shortest_paths(g, v)
        total_dist = sum(sp_lengths)
        cc[v] = if total_dist > 0.0 n / total_dist else 0.0 end
    end
    return cc
end

function eigenvector_centrality_measure(g::Graph; tol=1e-6, max_iter=100)
    n = nv(g)
    v = ones(Float64, n) / n
    for _ in 1:max_iter
        v_new = adjmat(g) * v
        v_new /= norm(v_new, 1)
        if norm(v_new - v) < tol
            return v_new
        end
        v = v_new
    end
    return v
end
