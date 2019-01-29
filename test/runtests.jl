using Tries

trie = Trie( 0.0, 2, 2, 2 )

trie[1,1,1] = 1.0
trie[1,1,2] = 1.0
trie[1,2,1] = 1.0

trie.data[1].data[1].data[1]
trie.data[1].data[1].data[2]
trie.data[1].data[2].data[1]
trie.data[1].data[2].data[2]



