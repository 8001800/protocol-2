pragma solidity ^0.4.21;

import "../provider/ProviderRegistry.sol";

contract IdentityDatabase {
    ProviderRegistry public providerRegistry;

    function IdentityDatabase(ProviderRegistry _providerRegistry) public {
        providerRegistry = _providerRegistry;
    }

    mapping (uint256 => mapping (address => mapping (uint256 => bytes32))) public bytes32Data;
    mapping (uint256 => mapping (address => mapping (uint256 => bytes))) public bytesData;

    function writeBytes32Field(
        uint256 providerId,
        address user,
        uint256 fieldId,
        bytes32 value
    ) external returns (bool) {
        if (msg.sender != providerRegistry.providerOwner(providerId)) {
            return false;
        }
        bytes32Data[providerId][user][fieldId] = value;
        return true;
    }

    function writeBytesField(
        uint256 providerId,
        address user,
        uint256 fieldId,
        bytes value
    ) external returns (bool) {
        if (msg.sender != providerRegistry.providerOwner(providerId)) {
            return false;
        }
        bytesData[providerId][user][fieldId] = value;
        return true;
    }
}