pragma solidity ^0.4.21;

import "../AbacusCoordinator.sol";
import "../provider/ProviderRegistry.sol";

/**
 * @title IdentityCoordinator
 * @dev Coordinates identity service providers.
 * Identity providers subscribe to `IdentityVerificationRequested` events and provide their
 * services, writing the results on-chain.
 */
contract IdentityCoordinator is AbacusCoordinator {
    ProviderRegistry public providerRegistry;

    function IdentityCoordinator(ProviderRegistry _providerRegistry) public {
        providerRegistry = _providerRegistry;
    }

    /**
     * @dev Emitted when an identity verification is requested.
     * This event is to be subscribed to and read by the provider off-chain.
     * Once the off-chain provider sees this event and ensures the correct cost
     * has been paid, they are to perform the identity verification then update the state
     * of their IdentityProvider.
     *
     * @param providerId The id of the provider.
     * @param providerVersion The version of the provider when the request was made.
     * @param user The address of the user that requests identity services.
     * @param args Any arguments that the identity provider may need.
     * @param cost The amount the user paid to the compliance provider.
     * @param requestId An arbitrary id to link the request to the off-chain database.
     */
    event IdentityVerificationRequested(
        uint256 indexed providerId,
        uint256 providerVersion,
        address user,
        string args,
        uint256 cost,
        uint256 requestId
    );

    /**
     * @dev Emitted when an identity verification has been performed.
     *
     * @param providerId The id of the provider.
     * @param user The address of the user that requests identity services.
     * @param requestId An arbitrary id to link the request to the off-chain database.
     */
    event IdentityVerificationPerformed(
        uint256 indexed providerId,
        address user,
        uint256 requestId
    );

    /**
     * @dev Mapping of user address => requestId => escrow.
     * Ensures no duplicate requests were sent.
     */
    mapping (address => mapping (uint256 => uint256)) requestEscrows;

    /**
     * @dev Requests verification of identity from a provider.
     *
     * @param providerId The id of the provider.
     * @param args Any arguments that the identity provider may need.
     * @param cost The amount the user paid to the compliance provider.
     * @param requestId An arbitrary id to link the request to the off-chain database.
     */
    function requestVerification(
        uint256 providerId,
        string args,
        uint256 cost,
        uint256 requestId,
        uint256 expiryBlocks
    ) external returns (bool)
    {
        address owner = providerRegistry.providerOwner(providerId);
        // Ensure that the request id is "unique"
        if (requestEscrows[msg.sender][requestId] != 0) {
            return false;
        }

        uint256 escrowId = kernel.beginEscrow(msg.sender, owner, cost, expiryBlocks);
        if (escrowId == 0) {
            return false;
        }
        requestEscrows[msg.sender][requestId] = escrowId;

        emit IdentityVerificationRequested(
            providerId,
            providerRegistry.latestProviderVersion(providerId),
            msg.sender,
            args,
            cost,
            requestId
        );

        return true;
    }

    function lockVerification(
        uint256 providerId,
        address user,
        uint256 requestId,
        uint256 expiryBlocks
    ) external returns (bool)
    {
        // Ensure requester is the provider owner
        if (msg.sender != providerRegistry.providerOwner(providerId)) {
            return false;
        }
        // Ensure request exists
        uint256 escrowId = requestEscrows[user][requestId];
        if (escrowId == 0) {
            return false;
        }
        // redeem kernel escrow
        return kernel.lockEscrow(escrowId, expiryBlocks);
    }

    function revokeVerification(uint256 requestId) external returns (bool) {
        uint256 escrowId = requestEscrows[msg.sender][requestId];
        if (escrowId == 0) {
            return false;
        }
        return kernel.revokeEscrow(escrowId);
    }

    /**
     * @dev Called by the identity provider when it completes its service.
     *
     * @param providerId The provider id.
     * @param user The address of the user getting verified.
     * @param requestId An arbitrary id to link the request to the off-chain database.
     */
    function onVerificationCompleted(
        uint256 providerId,
        address user,
        uint256 requestId
    ) external returns (bool)
    {
        // Ensure requester is the provider owner
        if (msg.sender != providerRegistry.providerOwner(providerId)) {
            return false;
        }
        // Ensure request exists
        uint256 escrowId = requestEscrows[user][requestId];
        if (escrowId == 0) {
            return false;
        }

        // redeem kernel escrow
        if (!kernel.redeemEscrow(escrowId)) {
            return false;
        }

        delete requestEscrows[user][requestId];
        emit IdentityVerificationPerformed(
            providerId,
            user,
            requestId
        );
        return true;
    }

}
