module WikipediaStructure

include("WikipediaDownload/WikipediaDownload.jl")

using .WikipediaDownload
export pull_wikipedia
export pull_page_network, pull_page_network_from_checkpoint

end # module WikipediaStructure
