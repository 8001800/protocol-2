pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";

contract SampleNFT is ERC721Full {
    uint public batchId;
    event Mint(
        address owner,
        uint tokenId
    );

    constructor(uint _batchId) public ERC721Full("SampleNFT", "SNFT"){
        batchId = _batchId;
    }

    function mint(address owner) public {
        _mint(owner, totalSupply());
        emit Mint(owner, totalSupply().sub(1));
    }
}