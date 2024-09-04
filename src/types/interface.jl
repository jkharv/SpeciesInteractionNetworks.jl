Base.eltype(::Bipartite{T}) where {T} = T
Base.eltype(::Unipartite{T}) where {T} = T

Base.eltype(::Undirected{T}) where {T} = T
Base.eltype(::Directed{T}) where {T} = T
Base.eltype(::Hyperedge{T}) where {T} = T
Base.eltype(::AnnotatedHyperedge{T}) where {T} = T

# @testitem "We can detect the type of a partiteness struct" begin
#     part = Bipartite([:A, :B, :C], [:a, :b, :c])
#     @test eltype(part) == Symbol

#     part = Unipartite(["A", "B", "C"])
#     @test eltype(part) == String
# end

species(N::Bipartite) = vcat(N.top, N.bottom)
species(N::Unipartite) = copy(N.margin)
species(N::SpeciesInteractionNetwork) = species(N.nodes)
species(N::Bipartite, dims::Integer) = dims==1 ? copy(N.top) : copy(N.bottom)
species(N::Unipartite, ::Integer) = copy(N.margin)
species(N::SpeciesInteractionNetwork, dims::Integer) = species(N.nodes, dims)

species(E::Undirected) = copy([E.sp1, E.sp2])
species(E::Directed) = copy([E.src, E.dst])
species(E::Hyperedge) = copy(E.spp)
species(E::AnnotatedHyperedge) = copy(E.spp)

richness(N::Partiteness) = length(species(N))
richness(N::Partiteness, dims::Integer) = length(species(N, dims))
richness(N::SpeciesInteractionNetwork) = length(species(N.nodes))
richness(N::SpeciesInteractionNetwork, dims::Integer) = length(species(N.nodes, dims))

interactions(N::SpeciesInteractionNetwork) = copy(N.edges)

function role(sp::T, int::AnnotatedHyperedge{T})::Symbol where T

    return roles(sp, int)[1] 
end

function roles(sp::T, int::AnnotatedHyperedge{T})::Vector{Symbol} where T

    indices = findall(x -> x == sp, int.spp)

    if isnothing(indices)

        throw(ArgumentError("Can't find $sp in this interaction: $int"))
    end

    return int.roles[indices]
end

function has_role(sp::T,
                  role::Symbol,
                  int::AnnotatedHyperedge{T})::Bool where T
    
    return role ∈ roles(sp, int)
end

function with_role(role::Symbol, 
                   int::AnnotatedHyperedge{T})::Vector{T} where T

    indices = findall(x -> x == role, int.roles)

    return int.spp[indices]
end

function subject(int::AnnotatedHyperedge{T})::T where T

    sbj = with_role(:subject, int)

    if length(sbj) ≠ 1

        error("subject() only works if an interaction has exactly one subject species")
    end

    return first(sbj)
end

function object(int::AnnotatedHyperedge{T})::T where T

    obj = with_role(:object, int)

    if length(obj) ≠ 1

        error("object() only works if an interaction has exactly one subject species")
    end

    return first(obj)
end

function isloop(int::AnnotatedHyperedge)::Bool

    return subject(int) == object(int)
end