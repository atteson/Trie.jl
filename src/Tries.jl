module Tries

export Trie

# The Trie's in DataStructures.jl only seem to allow strings for keys
# We're going to assume Vector{Int} for keys and fixed maximum in each dimension
mutable struct Trie{V,N <: Integer, T} <: AbstractArray{V,N}
    size::NTuple{N,Int}
    default::V
    data::Vector{Union{Missing,T}}
end

Base.size( t::Trie{V,N} ) where {V,T,N} = t.size

struct TrieNode{V,N,T}
    data::Vector{Union{Missing,T}}
end

# the code below assumes there are at least 2 levels
Trie( default::V, size::Int... ) where {V} =
    Trie( size, default, Vector{Union{Missing,TrieNode{V,length(size)-1}}}(missing, size[1]) )

@inline function Base.setindex!( head::Trie{V,N}, v::V, indices::Int... ) where {V,N}
    if ismissing(head.data[indices[1]])
        head.data[indices[1]] = TrieNode( Vector{Union{Missing,TrieNode{V,N-1}}}( missing, head.size[1] ) )
    end
    set!( head.data[indices[1]], head.size, v, indices... )
end

@inline function set!( node::TrieNode{V,M}, size::NTuple{N,Int}, v::V, indices::Int... ) where {V,M,N}
    if ismissing( node.data[indices[N-M]] )
        node.data[indices[n]] = TrieNode( Vector{Union{Missing,TrieNode{V,M-1}}}( missing, size[N-M] ) )
    end
    set!( node.data[indices[N-M]], size, v, indices... )
end

@inline function set!( node::TrieNode{V,1}, size::NTuple{N,Int}, v::V, indices::Int... ) where {V,N}
    if ismissing( node.data[indices[N-1]] )
        node.data[indices[N-1]] = TrieNode( Vector{Union{Missing,V}}( missing, size[N] ) )
    end
    node.data[indices[N-1]][indices[N]] = v
end

@inline function Base.getindex( head::Trie{V,N}, indices::Int... ) where {V,N}
    if ismissing( head.data[indices[1]] )
        return head.default
    else
        return get( head.data[indices[1]], head.default, indices... )
    end
end

@inline function get( node::TrieNode{TrieNode{V,M}}, v::V, indices::Int... ) where {V,M}
    if ismissing( node.data[indices[length(indices)-M]] )
        return v
    else
        return get( node.data[indices[length(indices)-M]], v, indices... )
    end
end

@inline get( node::TrieNode{V,1}, v::V, indices::Int... ) where {V} =
    ismissing( node.data[indices[end]] ) ? v : node.data[indices[end]]

end # module
