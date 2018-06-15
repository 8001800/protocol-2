pragma solidity ^0.4.24;

import "./ProviderRegistry.sol";

/**
 * @title AnnotationDatabase
 * @dev Stores annotation information about NFTs.
 */
contract AnnotationDatabase {
    ProviderRegistry public providerRegistry;

    constructor(ProviderRegistry _providerRegistry) public
    {
        providerRegistry = _providerRegistry;
    }

    struct Bytes32Entry {
        uint256 blockNumber;
        bytes32 value;
    }

    struct BytesEntry {
        uint256 blockNumber;
        bytes value;
    }

    event WriteBytes32Annotation(
        address nftAddr,
        uint256 nftId,
        uint256 providerId,
        uint256 fieldId,
        bytes32 value,
        uint256 blockNumber
    );

    event WriteBytesAnnotation(
        address nftAddr,
        uint256 nftId,
        uint256 providerId,
        uint256 fieldId,
        bytes value,
        uint256 blockNumber
    );

    mapping (address => mapping (uint256 => mapping (uint256 => mapping (uint256 => Bytes32Entry)))) public bytes32Data;
    mapping (address => mapping (uint256 => mapping (uint256 => mapping (uint256 => BytesEntry)))) public bytesData;

    function writeBytes32Field(
        address nftAddr,
        uint256 nftId,
        uint256 providerId,
        uint256 fieldId,
        bytes32 value
    ) external {
        require(msg.sender == providerRegistry.providerOwner(providerId));
        bytes32Data[nftAddr][nftId][providerId][fieldId] = Bytes32Entry({
            blockNumber: block.number,
            value: value
        });
        emit WriteBytes32Annotation({
            nftAddr: nftAddr,
            nftId: nftId,
            providerId: providerId,
            fieldId: fieldId,
            value: value,
            blockNumber: block.number
        });
    }

    function writeBytesField(
        address nftAddr,
        uint256 nftId,
        uint256 providerId,
        uint256 fieldId,
        bytes value
    ) external {
        require(msg.sender == providerRegistry.providerOwner(providerId));
        bytesData[nftAddr][nftId][providerId][fieldId] = BytesEntry({
            blockNumber: block.number,
            value: value
        });
        emit WriteBytesAnnotation({
            nftAddr: nftAddr,
            nftId: nftId,
            providerId: providerId,
            fieldId: fieldId,
            value: value,
            blockNumber: block.number
        });
    }

}
