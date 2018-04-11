pragma solidity ^0.4.21;

import "../provider/ProviderRegistry.sol";
import "../AbacusCoordinator.sol";

/**
 * @title IdentityCoordinator
 * @dev Coordinates identity service providers.
 * Identity providers subscribe to `IdentityVerificationRequested` events and provide their
 * services, writing the results on-chain.
 */
contract IdentityCoordinator is AbacusCoordinator {
    ProviderRegistry providerRegistry;

    function IdentityCoordinator(ProviderRegistry _providerRegistry) public
    {
        providerRegistry = _providerRegistry;
    }

    mapping (uint256 => mapping (address => mapping (uint256 => bytes32))) public bytes32Data;
    mapping (uint256 => mapping (address => mapping (uint256 => bytes))) public bytesData;

    function writeBytes32Field(
        address requester,
        uint256 requestId,
        uint256 providerId,
        address user,
        uint256 fieldId,
        bytes32 value
    ) external {
        require(msg.sender == providerRegistry.providerOwner(providerId));
        bytes32Data[providerId][user][fieldId] = value;
        kernel.onServiceCompleted(providerId, requester, requestId);
    }

    function writeBytesField(
        address requester,
        uint256 requestId,
        uint256 providerId,
        address user,
        uint256 fieldId,
        bytes value
    ) external {
        require(msg.sender == providerRegistry.providerOwner(providerId));
        bytesData[providerId][user][fieldId] = value;
        kernel.onServiceCompleted(providerId, requester, requestId);
    }

}
