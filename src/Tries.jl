module Tries

export Trie

# The Trie's in DataStructures.jl only seem to allow strings for keys
# We're going to assume Vector{Int} for keys and fixed maximum in each dimension
mutable struct Trie{V,N} <: AbstractArray{V,N}
    size::NTuple{N,Int}
    default::V
    data::Vector{Union{Missing,TrieNode{V,N-1}}}
end

Base.size( t::Trie{V,N} ) where {V,T,N} = t.size

struct TrieNode{V,N,T <: Union{TrieNode{V,N},V}}
    data::Vector{Union{Missing,T}}
end

# the code below assumes there are at least 2 levels
Trie( default::V, size::Int... ) where {V} =
    Trie( size, default, Vector{Union{Missing,TrieNode{V,N-1}}}(missing, size[1]) )

@inline function Base.setindex!( head::Trie{V,N}, v::V, indices::Int... ) where {V,N}
    if ismissing(head.data[indices[1]])
        head.data[indices[1]] = TrieNode( Vector{Union{Missing,TrieNode{V,N-1}}}( missing, head.size[1] ) )
    end
    set!( head.data[indices[1]], head.size, v, indices... )
end

@inline function set!( node::TrieNode{V,M}, size::NTuple{N,Int}, v::V, indices::Int... ) where {V,M,N}
    if ismissing( node.data[indices[N-M]] )
        if M == 1
            node.data[indices[n]] = TrieNode( Vector{Union{Missing,V}}( missing, size[N-M] ) )
        else
            node.data[indices[n]] = TrieNode( Vector{Union{Missing,TrieNode{V,M-1}}}( missing, size[N-M] ) )
        end
    end
    set!( node.data[indices[N-M]], size, v, indices... )
end

@inline set!( node::TrieNode{V,N}, size::NTuple{N,Int}, v::V, index::Int ) where {V,N} =
    node.data[index] = v

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
