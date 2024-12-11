module WikipediaStructure

include("WikipediaDownload/WikipediaDownload.jl")
using .WikipediaDownload

export pull_wikipedia
export pull_page_network, pull_page_network_from_checkpoint

include("Categories/Categories.jl")
using .Categories

export get_subgraph_with_category_labeling

include("Visualizations/Visualizations.jl")
using .Visualizations

export basicvis
export perform_graph_embedding

include("Community/Community.jl")
using .Community

export CommunityDetectionResult
export community_detection_in_subgraph
export sym_nmf_multiplicative_updates

include("GraphProcessing/GraphProcessing.jl")
using .GraphProcessing

export graph_to_edges_csv
export subgraph_to_edges_csv
export plot_communities
export plot_degree_dist

include("LouvainCommunities/LouvainCommunities.jl")
using .LouvainCommunities

include("Centrality/centrality.jl")
using .Centrality
export CentralityResult, analyze_category_centralities, load_page_data, load_category_data

end # module WikipediaStructure

