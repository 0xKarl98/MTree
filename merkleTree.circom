include "../node_modules/circomlib/circuits/poseidon.circom";


// Use poseidon as hash function 
template HashLeftRight(){
    signal input left ;
    signal input right; 
    signal output hash;
    
    component hasher = Poseidon(2);
    hasher.inputs[0] <== left ;
    hasher.inputs[1] <== right ;
    
    hash <== hasher.out ;

}
// if s == 0 returns [in[0], in[1]]
// if s == 1 returns [in[1], in[0]]
template Selector() {
	signal input in[2];
	signal input indice;
	signal output outs[2];

// enforces s to be 0 or 1 
	indice * (1 - indice) === 0; 
	outs[0] <== (in[1] - in[0]) * indice + in[0];
	outs[1] <== (in[0] - in[1]) * indice + in[1];
}

template TreeLayer(height) {
  var nBlocks = 1 << height;
  signal input ins[nBlocks * 2];
  signal output outs[nBlocks];

  component hash[nBlocks];
  for(var i = 0; i < nBlocks; i++) {
    hash[i] = Poseidon(2);
    hash[i].inputs[0] <== ins[i * 2];
    hash[i].inputs[1] <== ins[i * 2 + 1];
    hash[i].out ==> outs[i];
  }
}

// Given a set of leaf , output its root 
template MerkleTree(levels){
    // if the level is 2 , we need take 4 inputs as leaves
    signal input leaves[1<<levels];
    signal output root;
    
    component layers[levels];
    for (var level = levels -1 ; level >= 0 ; level--){
        layers[level] = TreeLayer(level);
         for(var i = 0; i < (1 << (level + 1)); i++) {
            layers[level].ins[i] <== level == levels - 1 ? leaves[i] : layers[level + 1].outs[i];
    }
}
root <== levels > 0 ? layers[0].outs[0] : leaves[0];

}

component main = MerkleTree(4) ;