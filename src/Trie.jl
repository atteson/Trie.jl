module Trie

# The Trie's in DataStructures.jl only seem to allow strings for keys
# We're going to assume Vector{Int} for keys and fixed maximum in each dimension
mutable struct TrieHead{V,T}
    size::Vector{Int}
    default::V
    data::Vector{Union{Missing,T}}
end

struct TrieNode{T}
    data::Vector{Union{Missing,T}}
end

TrieType( size::Vector{Int}, vt::DataType ) =
    isempty(size) ? vt : TrieType( size[2:end], TrieNode{vt} )

Trie( size::Vector{Int}, default::V ) where {V} =
    TrieHead( size, default, Vector{Union{TrieType( size[2:end], V ),Missing}}(missing, size[1]) )

function Base.setindex!( head::TrieHead{V,T}, v::V, indices::Int... ) where {V,T}
    if ismissing(head.data[indices[1]])
        head.data[indices[1]] = TrieNode( Vector{Union{Missing,T}}( missing, head.size[1] ) )
    end
    set!( head.data[indices[1]], head.size[2:end], v, indices[2:end] )
end

function set!( node::TrieNode{T}, size::Vector{Int}, v::V, indices::Int... ) where {T,V}
    if isempty(size)
        node.data[indices[1]] = v
    else
        if ismissing( node.data[indices[1]] )
            node.data[indices[1]] = Vector{Union{Missing,T}}( missing, size[1] )
        end
        set!( node.data[indices[1]], size[2:end], v, indices[2:end] )
    end
end

end # module
