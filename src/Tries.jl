module Tries

export Trie

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

TrieType( V::DataType, size::Int... ) =
    isempty(size) ? V : TrieType( TrieNode{V}, size[2:end]... )

Trie( default::V, size::Int... ) where {V} =
    TrieHead( [size...], default, Vector{Union{TrieType( V, size[2:end]... ),Missing}}(missing, size[1]) )

function Base.setindex!( head::TrieHead{V,TrieNode{T}}, v::V, indices::Int... ) where {V,T}
    if ismissing(head.data[indices[1]])
        head.data[indices[1]] = TrieNode( Vector{Union{Missing,T}}( missing, head.size[1] ) )
    end
    set!( head.data[indices[1]], head.size[2:end], v, indices[2:end]... )
end

function set!( node::TrieNode{TrieNode{T}}, size::Vector{Int}, v::V, indices::Int... ) where {T,V}
    if ismissing( node.data[indices[1]] )
        node.data[indices[1]] = TrieNode( Vector{Union{Missing,T}}( missing, size[1] ) )
    end
    set!( node.data[indices[1]], size[2:end], v, indices[2:end]... )
end

set!( node::TrieNode{V}, size::Vector{Int}, v::V, index::Int ) where {V} =
    node.data[index] = v

function Base.getindex( head::TrieHead{V,T}, indices::Int... ) where {V,T}
    if ismissing( head.data[indices[1]] )
        return head.default
    else
        return get( head.data[indices[1]], head.default, indices[2:end]... )
    end
end

function get( node::TrieNode{TrieNode{T}}, v::V, indices::Int... ) where {T,V}
    if ismissing( node.data[indices[1]] )
        return v
    else
        return get( node.data[indices[1]], v, indices[2:end]... )
    end
end

get( node::TrieNode{T}, v::V, indices::Int... ) where {T,V} =
    ismissing( node.data[indices[1]] ) ? v : node.data[indices[1]]

end # module
