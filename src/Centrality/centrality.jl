module Centrality

using Graphs
using LinearAlgebra
using SparseArrays
using Statistics
using StatsBase
import JLD2

export CentralityResult, analyze_category_centralities, load_page_data, load_category_data

"""
    struct CentralityResult

A structure to hold the centrality measures for categories.

Fields:
- `field_category_centrality`: Centralities for each category ID.
- `overall_summary`: Overall centrality metrics summary.
"""
struct CentralityResult
    field_category_centrality::Dict{Int64, Dict{Symbol, Float64}}
    overall_summary::Dict{Symbol, Vector{Float64}}
end

"""
    load_category_data(categories_file)

Loads category data from a JLD2 file.

Arguments:
- `categories_file`: Path to the JLD2 file containing category data.

Returns:
- A tuple `(categories_to_pages, category_to_id, category_graph)`:
    - `categories_to_pages`: Mapping from categories to pages.
    - `category_to_id`: Mapping from category names to their IDs.
    - `category_graph`: The category graph.
"""
function load_category_data(categories_file::String)
    return JLD2.load_object(categories_file)
end

"""
    load_page_data(pages_file)

Loads page data from a JLD2 file.

Arguments:
- `pages_file`: Path to the JLD2 file containing page data.

Returns:
- A tuple `(page_to_id, page_to_categories, page_graph)`:
    - `page_to_id`: Mapping from page names to their IDs.
    - `page_to_categories`: Mapping from pages to categories.
    - `page_graph`: The page graph.
"""
function load_page_data(pages_file::String)
    return JLD2.load_object(pages_file)
end

"""
    analyze_category_centralities(categories_file, field_category_ids)

Analyzes centrality measures for the categories in the category graph.

Arguments:
- `categories_file`: Path to the JLD2 file containing category data.
- `field_category_ids`: Vector of category IDs corresponding to the communities.

Returns:
- `CentralityResult`: An object containing:
    - `field_category_centrality`: Centrality metrics for each category.
    - `overall_summary`: Mean values of all centrality metrics.
"""
function analyze_category_centralities(categories_file::String, field_category_ids::Vector{Int64})::CentralityResult
    # Load category graph and metadata
    (categories_to_pages, category_to_id, category_graph) = load_category_data(categories_file)
    
    # Initialize centrality metrics
    degree_centrality = degree(category_graph)
    closeness_centrality = zeros(Float64, nv(category_graph))
    betweenness_centrality = betweenness_centrality(category_graph)
    eigenvector_centrality = eigenvector_centrality(category_graph)

    # Compute closeness centrality
    for node in 1:nv(category_graph)
        sp_lengths = Graphs.shortest_paths(category_graph, node)
        reachable_nodes = count(!isinf, sp_lengths) - 1
        if reachable_nodes > 0
            closeness_centrality[node] = reachable_nodes / sum(sp_lengths[.!isinf(sp_lengths)])
        end
    end

    # Map metrics to categories
    field_category_centrality = Dict()
    for category_id in field_category_ids
        field_category_centrality[category_id] = Dict(
            :degree_centrality => degree_centrality[category_id],
            :closeness_centrality => closeness_centrality[category_id],
            :betweenness_centrality => betweenness_centrality[category_id],
            :eigenvector_centrality => eigenvector_centrality[category_id]
        )
    end

    # Overall summary
    overall_summary = Dict(
        :degree_centrality => degree_centrality,
        :closeness_centrality => closeness_centrality,
        :betweenness_centrality => betweenness_centrality,
        :eigenvector_centrality => eigenvector_centrality
    )

    return CentralityResult(field_category_centrality, overall_summary)
end

end # module Centrality
