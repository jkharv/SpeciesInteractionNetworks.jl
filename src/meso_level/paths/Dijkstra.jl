# function shortestpath(
#     ::Type{Dijkstra},
#     N::SpeciesInteractionNetwork{<:Partiteness{T}, <:Interactions},
#     sp::T;
#     include_paths::Bool = false,
#     ) where {T}

#     @assert sp in species(N)

#     dist = Dict([s => Inf for s in species(N)])
#     pred = Dict{T, Union{Nothing, T}}([s => nothing for s in species(N)])
#     dist[sp] = 0.0
#     Q = species(N)

#     df = (x) -> _path_distance(_edgetype(N), x)

#     while !isempty(Q)

#         _, u = findmin(filter(p -> p.first ∈ Q, dist))
#         setdiff!(Q, [u])
#         whereto = filter(v -> v ∈ Q, successors(N, u))
#         if isempty(whereto)
#             break
#         end
#         for v in whereto
#             proposal = dist[u] + df(N[u, v])
#             if proposal < dist[v]
#                 dist[v] = proposal
#                 pred[v] = u
#             end
#         end
#     end

#     for s in species(N)

#         if (isinf(dist[s])) | (isnothing(pred[s]))
#             pop!(dist, s, nothing)
#             pop!(pred, s, nothing)
#         end
#     end

#     return include_paths ? (dist, pred) : dist
# end