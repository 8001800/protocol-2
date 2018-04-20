pragma solidity ^0.4.21;

import "./provider/ProviderRegistry.sol";

/**
 * @title AnnotationDatabase
 * @dev Stores annotation information about NFTs.
 */
contract AnnotationDatabase {
    ProviderRegistry public providerRegistry;

    function AnnotationDatabase(ProviderRegistry _providerRegistry) public
    {
        providerRegistry = _providerRegistry;
    }

    mapping (address => mapping (uint256 => mapping (uint256 => mapping (uint256 => bytes32)))) public bytes32Data;
    mapping (address => mapping (uint256 => mapping (uint256 => mapping (uint256 => bytes)))) public bytesData;

    function writeBytes32Field(
        address nftAddr,
        uint256 nftId,
        uint256 providerId,
        uint256 fieldId,
        bytes32 value
    ) external {
        require(msg.sender == providerRegistry.providerOwner(providerId));
        bytes32Data[nftAddr][nftId][providerId][fieldId] = value;
    }

    function writeBytesField(
        address nftAddr,
        uint256 nftId,
        uint256 providerId,
        uint256 fieldId,
        bytes value
    ) external {
        require(msg.sender == providerRegistry.providerOwner(providerId));
        bytesData[nftAddr][nftId][providerId][fieldId] = value;
    }

}
