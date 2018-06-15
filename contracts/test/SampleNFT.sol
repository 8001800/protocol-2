pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";

contract SampleNFT is ERC721Token{
     uint public batchId;
     event Mint(
         address owner,
         uint tokenId
     );

    constructor(uint _batchId) public ERC721Token("SampleNFT", "SNFT"){
        batchId = _batchId;
    }

    function mint(address owner){
        _mint(owner, allTokens.length);
        emit Mint(owner, allTokens.length);
    }
}