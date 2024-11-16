using HTTP
using JSON 
using Graphs
import JLD2
using URIParser
using URIs

function pull_page_network_from_checkpoint(categories_path::String, checkpoint_path::String, output_path::String)
    pages_to_ids = Dict{String, Int64}()
    page_graph = DiGraph()
    page_pulled = Dict{String, Bool}()
    pages_to_categories = Dict{String, Vector{String}}()

    # pull checkpoint
    (pages_to_ids, page_graph, page_pulled) = JLD2.load_object(checkpoint_path)   

    (category_pages, category_ids, G) = JLD2.load_object(categories_path)

    # get set of all pages in a category
    relevant_pages = Set{String}()
    for cat in values(category_pages)
        for page in cat
            push!(relevant_pages, page)
        end # for page
    end # for cat

    # get category mappings up front as well for easier checkpointing
    for category in keys(category_pages)
        for page in category_pages[category]
            # either create a new list if it is empty, or push to the end
            if isnothing(get(pages_to_categories, page, nothing))
                pages_to_categories[page] = [category]
            else 
                push!(pages_to_categories[page], category)
            end # if
        end # for page
    end # for category

    pull_links_from_checkpoint!(relevant_pages, pages_to_ids, page_graph, page_pulled, output_path)

    JLD2.save_object(joinpath(output_path, "pages.jld2"), (pages_to_ids, pages_to_categories, page_graph))
end # function pull_page_network_from_checkpoint

function pull_page_network(categories_path::String, output_path::String)
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
    page_pulled = Dict{String, Bool}()

    # get all pages to ids and categories upfront to allow for easier checkpointing
    for page in relevant_pages
        page_pulled[page] = false # for keeping track if its links have been pulled yet

        add_vertex!(page_graph) # add a vertex to the graph for this page
        pages_to_ids[page] = nv(page_graph) # save the id mapping
    end # for page

    # get category mappings up front as well for easier checkpointing
    for category in keys(category_pages)
        for page in category_pages[category]
            # either create a new list if it is empty, or push to the end
            if isnothing(get(pages_to_categories, page, nothing))
                pages_to_categories[page] = [category]
            else 
                push!(pages_to_categories[page], category)
            end # if
        end # for page
    end # for category

    pull_links_from_checkpoint!(relevant_pages, pages_to_ids, page_graph, page_pulled, output_path)

    JLD2.save_object(joinpath(output_path, "pages.jld2"), (pages_to_ids, pages_to_categories, page_graph))
end # function pull_page_network

function pull_links_from_checkpoint!(relevant_pages::Set{String}, pages_to_ids::Dict{String, Int64}, page_graph::DiGraph, page_pulled::Dict{String, Bool}, output_path::String)
    count = 0
    for page in relevant_pages
        count += 1
        # skip pages that are already pulled
        if page_pulled[page]
            @warn "Skipping $page as it has already been pulled"
            continue
        end # if

        @info "Pulling $page (count: $count)"

        
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
                # @error "$linked_page was linked to but is being skipped as it is not a subcategory of mathematics"
                continue
            end # if

            # then add the edge
            add_edge!(
                page_graph,
                pages_to_ids[page],
                pages_to_ids[linked_page]
            )
        end # for linked_page

        page_pulled[page] = true # save for later

        if count % 5000 == 0
            @info "Saving checkpoint"
            JLD2.save_object(joinpath(output_path, "pages$(count).jld2"), (pages_to_ids, page_graph, page_pulled))
        end # if 
    end # for page
end # function pull_links_from_checkpoint
