module WikipediaStructure

include("WikipediaDownload/WikipediaDownload.jl")

using .WikipediaDownload
export pull_wikipedia
export pull_page_network, pull_page_network_from_checkpoint

include("Categories/Categories.jl")

using .Categories
export get_subgraph_with_category_labeling

include("DegreeDistributionPlot/DegreeDistributionPlot.jl")

using .DegreeDistributionPlot
export plot_degree_dist

include("Visualizations/Visualizations.jl")

using .Visualizations

include("Community/Community.jl")
using .Community

include("Theorems/Theorems.jl")
using .Theorems

export community_detection_in_subgraph
export sym_nmf_multiplicative_updates

end # module WikipediaStructure

