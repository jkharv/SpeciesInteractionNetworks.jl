"""
    Partiteness{T}

The species in a network are stored in a parametric sub-type of `Partiteness`.
By default, this can be `Unipartite` or `Bipartite`. The inner type `T`
indicates what types can be used to represent species. Note that species
*cannot* be represented as integers, and will instead have a name. We recommend
using strings or symbols.
"""
abstract type Partiteness{T} end

abstract type Interaction{T} end

# For now it's a symbol, but I wanna seperate use of Symbol for roles cause in the
# future, something fancier for roles may be to come.
const RoleType = Symbol

struct SpeciesInteractionNetwork{P<:Partiteness, E<:Interaction, Q<:Union{Number, Missing}}

    nodes::P
    edges::Vector{E}
    edge_weights::Union{AbstractMatrix{Q}, Missing}
    node_weights::Union{Vector{Q}, Missing}

    function SpeciesInteractionNetwork(
        nodes::P, 
        edges::Vector{E};
        edge_weights::Union{AbstractMatrix{Q}, Missing} = missing,
        node_weights::Union{Vector{Q}, Missing} = missing) where 
        {P<:Partiteness, E<:Interaction, Q<:Union{Number, Missing}}

        new{P,E,Q}(nodes, edges, edge_weights, node_weights)
    end
end

"""
    Bipartite{T <: Any} <: Partiteness{T}

A bipartite set of species is represented by two sets of species, called `top`
and `bottom`. Both set of species are represented as `Vector{T}`, with a few
specific constraints:

1. `T` cannot be a `Number` (*i.e.* nodes must have names, or be other objects)
2. All species in `top` must be unique
2. All species in `bottom` must be unique
2. No species can be found in both `bottom` and `top`
"""
struct Bipartite{T <: Any} <: Partiteness{T}
    top::Vector{T}
    bottom::Vector{T}
    function Bipartite(top::Vector{T}, bottom::Vector{T}) where {T <: Any}
        if T <: Number
            throw(ArgumentError("The nodes IDs in a Bipartite set cannot be numbers"))
        end
        if ~allunique(top)
            throw(ArgumentError("The species in the top level of a bipartite network must be unique"))
        end
        if ~allunique(bottom)
            throw(ArgumentError("The species in the bottom level of a bipartite network must be unique"))
        end
        if ~allunique(vcat(bottom, top))
            throw(ArgumentError("The species in a bipartite network cannot appear in both levels"))
        end
        return new{T}(top, bottom)
    end
end

@testitem "We can construct a bipartite species set with symbols" begin
    set = Bipartite([:a, :b, :c], [:A, :B, :C])
    @test richness(set) == 6
end

@testitem "We can construct a bipartite species set with strings" begin
    set = Bipartite(["a", "b", "c"], ["A", "B", "C", "D"])
    @test richness(set) == 7
end

@testitem "We cannot construct a bipartite set with species on both sides" begin
    @test_throws ArgumentError Bipartite([:a, :b, :c], [:A, :a])
end

@testitem "We cannot construct a bipartite set with non-unique species" begin
    @test_throws ArgumentError Bipartite([:a, :b, :b], [:A, :B])
end

@testitem "We cannot construct a bipartite set with integer-valued species" begin
    @test_throws ArgumentError Bipartite([1, 2, 3, 4], [5, 6, 7, 8])
end

"""
    Unipartite{T <: Any} <: Partiteness{T}

A unipartite set of species is represented by a single set of species, called
`margin` internally. Both set of species are represented as `Vector{T}`, with a
few specific constraints:

1. `T` cannot be a `Number` (*i.e.* nodes must have names, or be other objects)
2. All species in `margin` must be unique
"""
struct Unipartite{T <: Any} <: Partiteness{T}
    margin::Vector{T}
    function Unipartite(margin::Vector{T}) where {T <: Any}
        if T <: Number
            throw(ArgumentError("The nodes IDs in a Unipartite set cannot be numbers"))
        end
        if ~allunique(margin)
            throw(ArgumentError("The species in a unipartite network must be unique"))
        end
        return new{T}(margin)
    end
end

@testitem "We can construct a unipartite species set with symbols" begin
    set = Unipartite([:a, :b, :c])
    @test richness(set) == 3
end

@testitem "We can construct a unipartite species set with strings" begin
    set = Unipartite(["a", "b", "c"])
    @test richness(set) == 3
end

@testitem "We cannot construct a unipartite set with non-unique species" begin
    @test_throws ArgumentError Unipartite([:a, :b, :b])
end

@testitem "We cannot construct a unipartite set with integer-valued species" begin
    @test_throws ArgumentError Unipartite([1, 2, 3, 4])
end

struct Directed{T} <: Interaction{T}

    src::T
    dst::T
end

struct Undirected{T} <: Interaction{T}

    sp1::T
    sp2::T
end

struct Hyperedge{T} <: Interaction{T}

    spp::Vector{T}
end

struct AnnotatedHyperedge{T} <: Interaction{T}

    spp::Vector{T}
    roles::Vector{RoleType}
end