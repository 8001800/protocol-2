pragma solidity ^0.4.21;

import "../provider/ProviderRegistry.sol";
import "../AbacusCoordinator.sol";

/**
 * @title AnnotationCoordinator
 * @dev Stores annotation information about NFTs.
 */
contract AnnotationCoordinator is AbacusCoordinator {
    ProviderRegistry public providerRegistry;

    function AnnotationCoordinator(ProviderRegistry _providerRegistry) public
    {
        providerRegistry = _providerRegistry;
    }

    mapping (uint256 => mapping (address => mapping (uint256 => mapping (uint256 => bytes32)))) public bytes32Data;
    mapping (uint256 => mapping (address => mapping (uint256 => mapping (uint256 => bytes)))) public bytesData;

    function writeBytes32Field(
        uint256 providerId,
        address nftAddr,
        uint256 nftId,
        uint256 fieldId,
        bytes32 value
    ) external {
        require(msg.sender == providerRegistry.providerOwner(providerId));
        bytes32Data[providerId][nftAddr][nftId][fieldId] = value;
    }

    function writeBytesField(
        uint256 providerId,
        address nftAddr,
        uint256 nftId,
        uint256 fieldId,
        bytes value
    ) external {
        require(msg.sender == providerRegistry.providerOwner(providerId));
        bytesData[providerId][nftAddr][nftId][fieldId] = value;
    }

}
