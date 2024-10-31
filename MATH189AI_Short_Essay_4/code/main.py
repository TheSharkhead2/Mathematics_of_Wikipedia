import networkx as nx 
import numpy as np
from matplotlib import pyplot as plt 
from mpl_toolkits.axes_grid1 import make_axes_locatable

def main(): 
    G = nx.read_gml("dolphins.gml")

    # degree distribution
    degs = G.degree()

    deg_seq = [d for _, d in degs]

    plt.hist(
        deg_seq, 
        max(deg_seq),
        edgecolor='black',
        linewidth=1
    )
    plt.title("Degree Distribution")
    plt.xlabel("Degree")
    plt.ylabel("Number of Nodes")
    # plt.show()
    plt.savefig("../images/degree_hist.pdf")

    # centrality
    c_dict = nx.closeness_centrality(G)
    c = np.array(list(c_dict.values()))

    plt.figure(0)
    # colorbar fixes and title fixes thanks to Claude 3.5 Sonnet

    fig, ax = plt.subplots(figsize=(10,7))
    
    nx.draw(G,
        ax=ax,
        with_labels=True,
        node_size=1000*c,
        node_color=c,
        cmap='cool',
        font_size=6,
        pos=nx.spring_layout(G)
    )

    divider = make_axes_locatable(ax)
    cax = divider.append_axes("right", size="2%", pad=0.2)

    # color bar: https://stackoverflow.com/questions/26739248/how-to-add-a-simple-colorbar-to-a-network-graph-plot-in-python
    sm = plt.cm.ScalarMappable(
        cmap="cool",
        norm=plt.Normalize(vmin = min(c), vmax=max(c))
    )
    sm._A = []

    plt.suptitle("Closeness Centrality")
    plt.colorbar(sm, cax=cax)
    plt.tight_layout()
    plt.savefig("../images/centrality.pdf")
    plt.close(fig)
    print(G)

if __name__ == "__main__":
    main()
