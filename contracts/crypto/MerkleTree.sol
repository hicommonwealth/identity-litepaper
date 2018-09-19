/*    
    copyright 2018 to the Commonwealth-HQ Authors

    This file is part of Commonwealth-HQ.

    Commonwealth-HQ is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Commonwealth-HQ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Commonwealth-HQ.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity ^0.4.24;

contract MerkleTree {
    mapping (bytes32 => bool) public serials;
    mapping (bytes32 => bool) public roots;
    uint public tree_depth = 29;
    uint public no_leaves = 536870912;
    struct Mtree {
        uint cur;
        bytes32[536870912][30] leaves2;
    }

    Mtree public MT;

    event leafAdded(uint index);

    //Merkletree.append(com)
    function insert(bytes32 com) internal returns (bool res) {
        require (MT.cur != no_leaves - 1);
        MT.leaves2[0][MT.cur] = com;
        updateTree();
        leafAdded(MT.cur);
        MT.cur++;
   
        return true;
    }


    function getMerkleProof(uint index) constant returns (bytes32[29], uint[29]) {

        uint[29] memory address_bits;
        bytes32[29] memory merkleProof;

        for (uint i=0 ; i < tree_depth; i++) {
            address_bits[i] = index%2;
            if (index%2 == 0) {
                merkleProof[i] = getUniqueLeaf(MT.leaves2[i][index + 1],i);
            }
            else {
                merkleProof[i] = getUniqueLeaf(MT.leaves2[i][index - 1],i);
            }
            index = uint(index/2);
        }
        return(merkleProof, address_bits);   
    }

    function getUniqueLeaf(bytes32 leaf, uint depth)
        pure returns (bytes32)
    {
        if (leaf == 0x0) {
            for (uint i=0;i<depth;i++) {
                leaf = sha256(leaf, leaf);
            }
        }
        return(leaf);
    }
    
    function updateTree() internal returns(bytes32 root) {
        uint CurrentIndex = MT.cur;
        bytes32 leaf1;
        bytes32 leaf2;
        for (uint i=0 ; i < tree_depth; i++) {
            uint NextIndex = uint(CurrentIndex/2);
            if (CurrentIndex%2 == 0) {
                leaf1 =  MT.leaves2[i][CurrentIndex];
                leaf2 = getUniqueLeaf(MT.leaves2[i][CurrentIndex + 1], i);
            } else {
                leaf1 = getUniqueLeaf(MT.leaves2[i][CurrentIndex - 1], i);
                leaf2 =  MT.leaves2[i][CurrentIndex];
            }
            MT.leaves2[i+1][NextIndex] = (sha256( leaf1, leaf2));
            CurrentIndex = NextIndex;
        }
        return MT.leaves2[tree_depth][0];
    }
    
   
    function getLeaf(uint j,uint k) constant returns (bytes32 root) {
        root = MT.leaves2[j][k];
    }

    function getRoot() constant returns(bytes32 root) {
        root = MT.leaves2[tree_depth][0];
    }

}