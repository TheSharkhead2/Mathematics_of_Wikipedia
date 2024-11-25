module WikipediaStructure

include("WikipediaDownload/WikipediaDownload.jl")

using .WikipediaDownload
export pull_wikipedia
export pull_page_network, pull_page_network_from_checkpoint

include("Categories/Categories.jl")

using .Categories
export mathematics_fields_categories 

end # module WikipediaStructure

