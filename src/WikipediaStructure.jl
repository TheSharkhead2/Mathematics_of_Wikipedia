module WikipediaStructure

include("WikipediaDownload/WikipediaDownload.jl")

using .WikipediaDownload
export pull_wikipedia
export pull_page_network

end # module WikipediaStructure
