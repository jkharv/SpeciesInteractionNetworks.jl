"""
    isdegenerate(N::SpeciesInteractionNetwork{<:Bipartite, <:Interactions})

A bipartite network is degenerate if it has species with no interactions.
"""
function isdegenerate(N::SpeciesInteractionNetwork{<:Bipartite, <:Interactions})
    top = any([isempty(successors(N, sp)) for sp in species(N,1)])
    bot = any([isempty(predecessors(N, sp)) for sp in species(N,2)])
    return (top | bot)
end

"""
    isdegenerate(N::SpeciesInteractionNetwork{<:Unipartite, <:Interactions}, allow_self_interactions::Bool=true)

A unipartite network is degenerate if it has species with no interactions. In
some cases, it is useful to consider that a species with only self-interactions
is disconnected from the network -- this can be done by using `false` as the
second argument (the default is to *allow* species with only self interactions
to remain).
"""
function isdegenerate(N::SpeciesInteractionNetwork{<:Unipartite, <:Interactions}, allow_self_interactions::Bool=true)
    isdisconnected = fill(false, richness(N))
    for (i,sp) in enumerate(species(N))
        nei = unique(predecessors(N,sp) ∪ successors(N, sp))
        if !allow_self_interactions
            filter!(isequal(sp), nei)
        end
        isdisconnected[i] = isempty(nei)
    end
    return any(isdisconnected)
end

@testitem "We can identify a network with all disconnected species" begin
    edges = Binary(zeros(Bool, (4, 3)))
    nodes = Bipartite(edges)
    @test isdegenerate(SpeciesInteractionNetwork(nodes, edges))
end

@testitem "We can identify a network with some disconnected species" begin
    edges = Binary(Bool[0 0 0 0; 0 0 0 1; 0 1 1 1; 0 0 0 0])
    nodes = Bipartite(edges)
    @test isdegenerate(SpeciesInteractionNetwork(nodes, edges))
end

@testitem "We can identify a degenerate probabilistic network" begin
    edges = Probabilistic(Float64[0 0 0 0; 0 0 0 0.2; 0 0.9 0.7 0.1; 0 0 0 0])
    nodes = Bipartite(edges)
    @test isdegenerate(SpeciesInteractionNetwork(nodes, edges))
end

@testitem "We can identify a degenerate Quantitative network" begin
    edges = Quantitative(Float64[0 0 0 0; 0 0 0 2; 0 9 7 1; 0 0 0 0])
    nodes = Bipartite(edges)
    @test isdegenerate(SpeciesInteractionNetwork(nodes, edges))
end