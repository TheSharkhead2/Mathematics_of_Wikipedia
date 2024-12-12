```julia
import JLD2 
using Graphs
using Revise
using WikipediaStructure

cdr0 = JLD2.load_object("full_graph_cdr_20241211_25cat.jld2")

using SGtSNEpi
using CairoMakie, Colors
using GLMakie
using LinearAlgebra
using SparseArrays

set_theme!(theme_black())

using Random, Distributions 

cmap = distinguishable_colors(
           25,
           [RGB(1,1,1), RGB(0,0,0)], dropseed=true)



found_embed0 = show_embedding( cdr0.Y, cdr0.found_labels ; A = adjacency_matrix(SimpleGraph(cdr0.subgraph)), res = (2000, 2000), lwd_in = 0.05, lwd_out = 0.001, edge_alpha=0.4, cmap = cmap[1:25])

hidedecorations!(found_embed0.content[1]) # removes axis labels and whatnot`
hidespines!(found_embed0.content[1]) # fully removes axis

save("/home/theo/Documents/Obsidian_Vault/HMC/Semester 5/MATH189AI/Note Images/20241211_old_cdrs/found_embed0_Y2_new.png", found_embed0)
```
![[found_embed0_Y2_new.png]]
For convenience, I first want to list all top pages for each category
#### Community top pages 
##### 1 
3584 nodes
```
 "Function (mathematics)"
 "Information theory"
 "Set (mathematics)"
 "Mathematical logic"
 "Set theory"
 "Category theory"
 "Euclidean geometry"
 "Subset"
 "Type theory"
 "Isomorphism"
```
##### 2
4690 nodes
```
"Geographic coordinate system"
 "Radar"
 "Template:Flag-stub"
 "Template:Poland-heraldry-stub"
 "Torpedo"
 "Air traffic control"
 "Lockheed Corporation"
 "Phased array"
 "Raytheon"
 ```
##### 3 
27987 nodes
```
"Mathematics Genealogy Project"
 "American Mathematical Society"
 "Template:Mathematician-stub"
 "Algorithm"
 "Edmund F. Robertson"
 "MacTutor History of Mathematics Archive"
 "European Mathematical Society"
 "Notices of the American Mathematical Society"
 "Operations research"
 "Mathematical Association of America"
 "Isaac Newton"
 ```
##### 4
6045 nodes
```
 "ISO 4"
 "HTML"
 "Measurement"
 "SVG"
 "PDF"
 "Vector graphics"
 "Data compression"
 "Metadata"
 "Template:Measurement-stub"
 "Pixel"
 ```
##### 5
2554 nodes 
```
"Google Scholar"
 "YouTube"
 "Google"
 "Google Books"
 "Go (programming language)"
 "Google Chrome"
 "Google Play"
 "Google Maps"
 "Google Search"
```
##### 6 
2824 nodes 
```
"Game theory"
 "John von Neumann"
 "Go (game)"
 "Claude Shannon"
 "Herbert A. Simon"
 "Decision theory"
 "Mathematical economics"
 "Kenneth Arrow"
 "Econometric Society"
 "Research Papers in Economics"
 ```
##### 7 
2551 nodes 
```
"Probability theory"
 "Probability"
 "Signal processing"
 "Stochastic process"
 "Actuary"
 "Mathematical finance"
 "Population genetics"
 "Mathematical statistics"
 "Stochastic differential equation"
```
##### 8
400 nodes 
```
"Oxyrhynchus Papyri"
 "Oxyrhynchus"
 "Oxyrhynchus Gospels"
 "Papyrus Oxyrhynchus 840"
 "Papyrus 1"
 "Allegory of the cave"
 "Gospel of Thomas"
 "Papyrus 13"
 "Amarna letter EA 19"
 "Papyrus 9"
```
##### 9 
10323 nodes 
```
"Artificial intelligence"
 "Machine learning"
 "Wikidata"
 "Unmanned aerial vehicle"
 "Robotics"
 "Computer vision"
 "Theoretical computer science"
 "Natural language processing"
 "Digital image processing"
 "Data mining"
 ```
##### 10 
1500 nodes 
```
"Functional analysis"
 "Graduate Texts in Mathematics"
 "Hilbert space"
 "Calculus of variations"
 "Measure (mathematics)"
 "Lp space"
 "Banach space"
 "Convex set"
 "Hausdorff space"
 "Finite element method"
 ```
##### 11
2975 nodes 
```
"Cryptography"
 "National Security Agency"
 "National Institute of Standards and Technology"
 "Cryptographic hash function"
 "Bletchley Park"
 "Encryption"
 "Cryptanalysis"
 "Cryptocurrency"
 "Authentication"
 ```
##### 12
1226 nodes 
```
"Prime number"
 "Natural number"
 "On-Line Encyclopedia of Integer Sequences"
 "Three-dimensional space"
 "Billion"
 "Natural language"
 "Modular arithmetic"
 "Permutation"
 "Exponentiation"
```
##### 13
1404
```
"Orbital period"
 "Orbital inclination"
 "Epoch (astronomy)"
 "Semi-major and semi-minor axes"
 "Kilometre"
 "Osculating orbit"
 "Argument of periapsis"
 "Mean anomaly"
 "Longitude of the ascending node"
 ```
##### 14
960 nodes
```
"Chess"
 "Chessgames.com"
 "Algebraic notation (chess)"
 "AlphaZero"
 "Computer chess"
 "Chess opening"
 "Deep Blue (chess computer)"
 "Encyclopaedia of Chess Openings"
 "Chess.com"
 ```
##### 15
3067 nodes 
```
"IOS"
 "Apple Inc."
 "TechCrunch"
 "Victor Entertainment"
 "Engadget"
 "AOL"
 "IPhone"
 "ITunes"
 "Camera"
 "IPad"
 "Safari (web browser)"
 ```
##### 16 
2632 nodes 
```
"Geometry"
 "MathWorld"
 "Triangle"
 "Polyhedron"
 "Polygon"
 "Vertex (geometry)"
 "Tetrahedron"
 "Cube"
 "Tessellation"
 "Octahedron"
 "Regular polygon"
 "Martin Gardner"
 ```
##### 17
1189 nodes 
```
"The New York Times"
 "The Guardian"
 "BBC News"
 "Tony Blair"
 "The Intercept"
 "Black Lives Matter"
 "George Floyd protests"
 "Murder of George Floyd"
 "Anonymous (hacker group)"
 "Woke"
 "Closed-circuit television"
```
##### 18
30869 nodes 
```
"Wayback Machine"
 "HTML element"
 "Linux"
 "Twitter"
 "Microsoft"
 "Computer scientist"
 "Metacritic"
 "GitHub"
 "Java (programming language)"
 "MacOS"
 "Python (programming language)"
 "C++"
 ```
##### 19
873 nodes 
```
 "Normal distribution"
 "Expected value"
 "Template:Statistics-stub"
 "Probability density function"
 "Dirac delta function"
 "Cumulative distribution function"
 "Gamma function"
 "Poisson distribution"
 "Binomial distribution"
 "Exponential distribution"
 ```
##### 20
10726 nodes 
```
"Internet Archive"
 "Institute for Advanced Study"
 "Mass"
 "Albert Einstein"
 "Frequency"
 "Biodiversity Heritage Library"
 "Medical imaging"
 "Thermodynamics"
 "Statistical mechanics"
 "Project Gutenberg"
 ```
##### 21
583 nodes 
```
"Template:Anthem-stub"
 "State of Palestine"
 "60th parallel south"
 "Country code top-level domain"
 "ISO 3166-1 alpha-2"
 ".eu"
 "Country code"
 "Komatsu Limited"
 "Geohash"
 "World Geographic Reference System"
 ".in"
 "ISO 3166-1 alpha-3"
 ```
##### 22
5044 nodes 
```
"Tweet (social media)"
 "Aperture"
 "X-ray"
 "Remote sensing"
 "Watt"
 "Hertz"
 "Lockheed Martin"
 "Charge-coupled device"
 "Sounding rocket"
 "Equator"
 "Astronomical unit"
 "Apsis"
 ```
##### 23
719 nodes 
```
"Integer"
 "Decimal"
 "Binary number"
 "Hexadecimal"
 "Neil Sloane"
 "Roman numerals"
 "Ternary numeral system"
 "Greek numerals"
 "Octal"
 "1"
 "Atomic number"
 ```
##### 24
3540 nodes 
```
"Statistics"
 "Statistician"
 "Econometrics"
 "Probability distribution"
 "Random variable"
 "Variance"
 "Cartography"
 "Data"
 "Actuarial science"
 "Institute of Mathematical Statistics"
 "Fourier analysis"
 "Standard deviation"
 "Time series"
 ```
##### 25
972 nodes 
```
"Android (operating system)"
 "Unix-like"
 "Linux kernel"
 "Debian"
 "Linux distribution"
 "GNU"
 "ChromeOS"
 "Ubuntu"
 "GNOME"
 "Tails (operating system)"
 "DivestOS"
 "Red Hat Enterprise Linux"
 "Red Hat"
 "Fedora Linux"
 "Arch Linux"
 ```

Community visualizations:
```julia
function visualize_community(cdr::CommunityDetectionResult, community_id::Int64, cmap; gray=colorant"#575757")
	cmap_new = [gray for _ in 1:length(cdr.ranked_found_community_page_names)]
	cmap_new[community_id] = cmap[community_id]

	embed = show_embedding( cdr.Y, cdr.found_labels ; A = adjacency_matrix(SimpleGraph(cdr.subgraph)), res = (2000, 2000), lwd_in = 0.05, lwd_out = 0.001, edge_alpha=0.4, cmap = cmap_new)

	hidedecorations!(embed.content[1]) # removes axis labels and whatnot`
	hidespines!(embed.content[1]) # fully removes axis

	embed 
end # function visualize_community
```

I need this lol: 
```julia
function print_as_itemize(community::Vector{String}, topk::Int64)
	for i in 1:topk
		println("\\item[] $(community[i])")
	end
end
```

##### Community 1
```julia
found_embed_cat1 = visualize_community(cdr0, 1, cmap)

save("/home/theo/Documents/Obsidian_Vault/HMC/Semester 5/MATH189AI/Note Images/20241211_community_vis/community_1.png", found_embed_cat1)

(com_1_subgraph, com1_vmap) = induced_subgraph(cdr0.subgraph, cdr0.ranked_found_community_page_ids[1])
plot_degree_dist(com_1_subgraph; type = "indegree", bucketSize = 8, series_color=cmap[1], output_path="/home/theo/Documents/Obsidian_Vault/HMC/Semester 5/MATH189AI/Note Images/20241211_community_vis/community_1_indegree.png")
plot_degree_dist(com_1_subgraph; type = "outdegree", bucketSize = 8, series_color=cmap[1], output_path="/home/theo/Documents/Obsidian_Vault/HMC/Semester 5/MATH189AI/Note Images/20241211_community_vis/community_1_outdegree.png")
```
##### Community 3
```julia
print_as_itemize(cdr0.ranked_found_community_page_names[3], 10)

found_embed_cat3 = visualize_community(cdr0, 3, cmap)

save("/home/theo/Documents/HMC/HMC_Semester_5/MATH189AI/MATH189_Project/presentation_images/community_3.png", found_embed_cat3)
```
Let's look closer at this community specifically 
```julia
community_3_ids = [cdr0.subgraph_vmap[i] for i in cdr0.ranked_found_community_page_ids[3]]  

cdr_community3 = community_detection_in_subgraph("data/pages/pages.jld2", "data/categories.jld2", community_3_ids, 25; community_detection_max_iter=2000, graph_embedding_max_iter = 10000, graph_embedding_early_exag = 2000, graph_embedding_eta=250)

JLD2.save_object("community3_cdr.jld2", cdr_community3)

cmap3 = distinguishable_colors(
           25,
           [RGB(1,1,1), RGB(0,0,0)], dropseed=true)

found_embed_c3 = show_embedding( cdr_community3.Y, cdr_community3.found_labels ; A = adjacency_matrix(SimpleGraph(cdr_community3.subgraph)), res = (2000, 2000), lwd_in = 0.05, lwd_out = 0.001, edge_alpha=0.4, cmap = cmap3)
```
NEED TO PUT THIS STUFF IN TO PRESENTATION
##### Community 7
```julia
print_as_itemize(cdr0.ranked_found_community_page_names[7], 10)

found_embed_cat7 = visualize_community(cdr0, 7, cmap)

save("/home/theo/Documents/HMC/HMC_Semester_5/MATH189AI/MATH189_Project/presentation_images/community_7.png", found_embed_cat7)
```

##### Community 10 
```julia
print_as_itemize(cdr0.ranked_found_community_page_names[10], 10)

found_embed_cat10 = visualize_community(cdr0, 10, cmap)

save("/home/theo/Documents/HMC/HMC_Semester_5/MATH189AI/MATH189_Project/presentation_images/community_10.png", found_embed_cat10)
```
##### Community 12 
```julia
print_as_itemize(cdr0.ranked_found_community_page_names[12], 10)

found_embed_cat12 = visualize_community(cdr0, 12, cmap)

save("/home/theo/Documents/HMC/HMC_Semester_5/MATH189AI/MATH189_Project/presentation_images/community_12.png", found_embed_cat12)
```
##### Community 19 
```julia
print_as_itemize(cdr0.ranked_found_community_page_names[19], 10)

found_embed_cat19 = visualize_community(cdr0, 19, cmap)

save("/home/theo/Documents/HMC/HMC_Semester_5/MATH189AI/MATH189_Project/presentation_images/community_19.png", found_embed_cat19)
```
##### Community 23 
```julia
print_as_itemize(cdr0.ranked_found_community_page_names[23], 10)

found_embed_cat23 = visualize_community(cdr0, 23, cmap)

save("/home/theo/Documents/HMC/HMC_Semester_5/MATH189AI/MATH189_Project/presentation_images/community_23.png", found_embed_cat23)
```
##### Community 24
```julia
print_as_itemize(cdr0.ranked_found_community_page_names[24], 10)

found_embed_cat24 = visualize_community(cdr0, 24, cmap)

save("/home/theo/Documents/HMC/HMC_Semester_5/MATH189AI/MATH189_Project/presentation_images/community_24.png", found_embed_cat24)
```
##### Community 25
```julia
print_as_itemize(cdr0.ranked_found_community_page_names[25], 10)

found_embed_cat25 = visualize_community(cdr0, 25, cmap)

save("/home/theo/Documents/HMC/HMC_Semester_5/MATH189AI/MATH189_Project/presentation_images/community_25.png", found_embed_cat25)
```
