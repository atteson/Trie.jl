using Tries
using Random
using Profile
using ProfileView

trie = Trie( 0.0, 2, 2, 2 )

trie[1,1,1] = 1.0
trie[1,1,2] = 2.0
trie[1,2,1] = 3.0

@assert( trie[1,1,1] == 1.0 )
@assert( trie[1,1,2] == 2.0 )
@assert( trie[1,2,1] == 3.0 )
@assert( trie[1,2,2] == 0.0 )
@assert( trie[2,1,1] == 0.0 )
@assert( trie[2,1,2] == 0.0 )
@assert( trie[2,2,1] == 0.0 )
@assert( trie[2,2,2] == 0.0 )

function setup()
    Random.seed!(1)
    t = Trie( 0.0, 100, 100, 100 )
    a = rand( 100_000 )
    b = zeros( 1_000_000 )
    allindices = Int[]
    for x in a
        indices = rand( 1:100, 3 )
        while t[indices...] != 0.0
            indices = rand( 1:100, 3 )
        end
        t[indices...] = x
        index = (indices[1]-1)*10_000 + (indices[2]-1)*100 + indices[3]
        b[index] = x
        push!( allindices, index )
    end
    return (a,sort(allindices),b,t)
end

function Base.sum( t::Tries.TrieHead )
    s = 0.0
    for i = 1:100
        for j = 1:100
            for k = 1:100
                s += t[i,j,k]
            end
        end
    end
    return s
end

(a,indices,b,t) = setup();
@time sum(b)
@time sum(b)

@time sum(t)
@time sum(t)

# an alternate possible representation
function f( a, indices )
    s = 0.0
    for i = 1:100
        for j = 1:100
            for k = 1:100
                index = (i-1)*10_000 + (j-1)*100 + k
                loc = searchsorted( indices, index )
                if loc.start <= loc.stop
                    s += a[loc.start]
                end
            end
        end
    end
    return s
end

@time f(a, indices)
@time f(a, indices)

