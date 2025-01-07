function shortestpath(
    ::Type{BellmanFord},
    N::SpeciesInteractionNetwork{<:Unipartite{T}, <:Interaction{T}},
    sp::T;
    include_paths::Bool = false
    ) where {T}

    @assert sp in species(N)

    dist = Dict([s => Inf for s in species(N)])
    pred = Dict{T, Union{T, Nothing}}([s => nothing for s in species(N)])
    dist[sp] = 0.0

    for _ ∈ 1:length(interactions(N)) - 1

        for int ∈ interactions(N)

            if (dist[subject(int)] + 1.0) < dist[object(int)]

                dist[object(int)] = dist[subject(int)] + 1
                pred[object(int)] = subject(int)
            end
        end
    end

    for s in species(N)

        if (isinf(dist[s])) | (isnothing(pred[s]))
            pop!(dist, s, nothing)
        end
    end

    return include_paths ? (dist, pred) : dist
end