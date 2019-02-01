module Tries

export Trie

# The Trie's in DataStructures.jl only seem to allow strings for keys
# We're going to assume Vector{Int} for keys and fixed maximum in each dimension
mutable struct Trie{V,T,N} <: AbstractArray{V,N}
    size::NTuple{N,Int}
    default::V
    data::Vector{Union{Missing,T}}
end

Base.size( t::Trie{V,T,N} ) where {V,T,N} = t.size

struct TrieNode{T}
    data::Vector{Union{Missing,T}}
end

TrieType( V::DataType, N::Int ) =
    N == 0 ? V : TrieType( TrieNode{V}, N-1 )

Trie( default::V, size::Int... ) where {V} =
    Trie( size, default, Vector{Union{TrieType( V, length(size)-1 ),Missing}}(missing, size[1]) )

Base.copy( head::Trie{V,TrieNode{T},N} ) where {V,T,N} =
    Trie( head.size, head.default, copy( head.data ) )

Base.copy( node::TrieNode{T} ) where {T} =
    TrieNode( copy( node.data ) )

@inline function Base.setindex!( head::Trie{V,TrieNode{T},N}, v::V, indices::Int... ) where {V,T,N}
    if ismissing(head.data[indices[1]])
        head.data[indices[1]] = TrieNode( Vector{Union{Missing,T}}( missing, head.size[2] ) )
    end
    set!( head.data[indices[1]], head.size, v, 2, indices... )
end

@inline function set!( node::TrieNode{TrieNode{T}}, size::NTuple{N,Int}, v::V, n::Int, indices::Int... ) where {V,T,N}
    if ismissing( node.data[indices[n]] )
        node.data[indices[n]] = TrieNode( Vector{Union{Missing,T}}( missing, size[n+1] ) )
    end
    set!( node.data[indices[n]], size, v, n+1, indices... )
end

@inline set!( node::TrieNode{V}, size::NTuple{N,Int}, v::V, n::Int, indices::Int... ) where {V,N} =
    node.data[indices[n]] = v

@inline function Base.getindex( head::Trie{V,T,N}, indices::Int... ) where {V,T,N}
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
