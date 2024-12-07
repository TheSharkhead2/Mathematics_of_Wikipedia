using SGtSNEpi, Random, Distributions
using CairoMakie, Colors, LinearAlgebra
using Graphs
using GLMakie, Makie

function perform_graph_embedding(
    G;
    lambda = 100.,
    alpha = 10,
    eta = 20,
    max_iter = 5000,
    early_exag = 500,
    np = 0,
    seed = 42,
)
    Random.seed!(seed) # seed for consistent results

    # initial embedding randomly pulled from Gaussian
    Y0 = rand(Normal(0, 10), (nv(G), 2))

    # perform embedding
    Y = sgtsnepi(
        adjacency_matrix(SimpleGraph(G)); # convert graph to undirected
        Y0 = Y0,
        λ = lambda,
        alpha = alpha,
        eta = eta,
        early_exag = early_exag,
        max_iter = max_iter,
        np = np,
        version = SGtSNEpi.NUCONV
    )

    return Y
end # function perform_graph_embedding
