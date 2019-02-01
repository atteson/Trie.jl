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

function Base.sum( t::Tries.Trie )
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

indices1 = div.( indices, 10_000 ) .+ 1;
indices2 = mod.(div.( indices, 100 ), 100 ) .+ 1;
indices3 = mod.( indices .- 1, 100 ) .+ 1;

function set( t::Tries.Trie, indices1, indices2, indices3 )
    for i = 1:length(indices1)
        t[indices1[i], indices2[i], indices3[i]] = rand()
    end
end

@time set( t, indices1, indices2, indices3 )
@time set( t, indices1, indices2, indices3 )

t = Trie( 0.0, 8, 2, 100000 )
t[1,1,3] = 1.0

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

