pragma solidity ^0.4.21;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "./AbacusInstrument.sol";

contract FungibleInstrument is AbacusInstrument, ERC20 { }

contract NonFungibleInstrument is AbacusInstrument, ERC721 { }