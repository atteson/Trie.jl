module Tries

export Trie

# The Trie's in DataStructures.jl only seem to allow strings for keys
# We're going to assume Vector{Int} for keys and fixed maximum in each dimension
mutable struct TrieHead{V,T,N} <: AbstractArray{V,N}
    size::NTuple{N,Int}
    default::V
    data::Vector{Union{Missing,T}}
end

Base.size( t::TrieHead{V,T,N} ) where {V,T,N} = t.size

struct TrieNode{T}
    data::Vector{Union{Missing,T}}
end

TrieType( V::DataType, size::Int... ) =
    isempty(size) ? V : TrieType( TrieNode{V}, size[2:end]... )

Trie( default::V, size::Int... ) where {V} =
    TrieHead( size, default, Vector{Union{TrieType( V, size[2:end]... ),Missing}}(missing, size[1]) )

@inline function Base.setindex!( head::TrieHead{V,TrieNode{T},N}, v::V, indices::Int... ) where {V,T,N}
    if ismissing(head.data[indices[1]])
        head.data[indices[1]] = TrieNode( Vector{Union{Missing,T}}( missing, head.size[1] ) )
    end
    set!( head.data[indices[1]], head.size, v, 2, indices... )
end

@inline function set!( node::TrieNode{TrieNode{T}}, size::NTuple{N,Int}, v::V, n::Int, indices::Int... ) where {V,T,N}
    if ismissing( node.data[indices[n]] )
        node.data[indices[n]] = TrieNode( Vector{Union{Missing,T}}( missing, size[n] ) )
    end
    set!( node.data[indices[n]], size, v, n+1, indices... )
end

@inline set!( node::TrieNode{V}, size::NTuple{N,Int}, v::V, n::Int, indices::Int... ) where {V,N} =
    node.data[indices[n]] = v

@inline function Base.getindex( head::TrieHead{V,T,N}, indices::Int... ) where {V,T,N}
    if ismissing( head.data[indices[1]] )
        return head.default
    else
        return get( head.data[indices[1]], head.default, 2, indices... )
    end
end

@inline function get( node::TrieNode{TrieNode{T}}, v::V, n::Int, indices::Int... ) where {T,V}
    if ismissing( node.data[indices[n]] )
        return v
    else
        return get( node.data[indices[n]], v, n+1, indices... )
    end
end

@inline get( node::TrieNode{T}, v::V, n::Int, indices::Int... ) where {T,V} =
    ismissing( node.data[indices[n]] ) ? v : node.data[indices[n]]

end # module
