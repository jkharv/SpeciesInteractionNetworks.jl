using Revise
using SpeciesInteractionNetworks


web = SpeciesInteractionNetwork(
    Unipartite([:s1, :s2]),
    [
        AnnotatedHyperedge([:s1, :s2], [:subject, :object]),
        AnnotatedHyperedge([:s2, :s1], [:subject, :object])
    ]
)

shortestpath(BellmanFord, web, :s2)

distancetobase(BellmanFord, web, :s1, mean)
