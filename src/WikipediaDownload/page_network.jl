using HTTP
using JSON 
using Graphs
import JLD2
using URIParser
using URIs

function pull_page_network(categories_path::String, output::String)
    (category_pages, category_ids, G) = JLD2.load_object(categories_path) # load category info

    # get set of all pages in a category
    relevant_pages = Set{String}()
    for cat in values(category_pages)
        for page in cat
            push!(relevant_pages, page)
        end # for page
    end # for cat

    pages_to_ids = Dict{String, Int64}()
    pages_to_categories = Dict{String, Vector{String}}()
    page_graph = DiGraph()
    
    count = 0
    for category in keys(category_pages)
        for page in category_pages[category]
            count += 1
            @info "On page $page (count: $count)"
            # # skip non-normal pages
            # if startswith(page, "Wikipedia:") || startswith(page, "File:")
            #     continue
            # end # if

            # if the page hasn't been given an ID yet, then give it an ID
            if isnothing(get(pages_to_ids, page, nothing))
                add_vertex!(page_graph)
                pages_to_ids[page] = nv(page_graph)

                # NOTE: that you can be in the graph but we haven't added your links yet
            end # if

            # create mapping from pages to the categories they are in
            if isnothing(get(pages_to_categories, page, nothing))
                pages_to_categories[page] = [category]

                # NOTE that we only didn't add categories when we haven't pulled this page yet
                # hence, pull page here: 

                uri_page = escapeuri(page)
                url = "https://en.wikipedia.org/w/api.php?action=parse&page=$(uri_page)&format=json"
                r = HTTP.request("GET", url)
                j = JSON.parse(String(r.body))
                
                # pull out all pages that have links to
                linked_pages = [x["*"] for x in j["parse"]["links"]]

                # then add edges
                for linked_page in linked_pages 
                    # skip pages that aren't a sub-category of math
                    if !(linked_page in relevant_pages)
                        @warn linked_page
                        continue
                    end # if

                    # add vertex for this page if it doesn't exist already
                    if isnothing(get(pages_to_ids, linked_page, nothing))
                        add_vertex!(page_graph)
                        pages_to_ids[linked_page] = nv(page_graph)
                    end # if

                    # then add the edge
                    add_edge!(
                        page_graph,
                        pages_to_ids[page],
                        pages_to_ids[linked_page]
                    )
                end # for linked_page
            else 
                push!(pages_to_categories[page], category)
            end # if
        end # for page
    end # for category

    JLD2.save_object(output, (pages_to_ids, pages_to_categories, page_graph))
end # function pull_page_network
