pragma solidity ^0.4.19;

import "../NeedsAbacus.sol";
import "../provider/ProviderRegistry.sol";

/**
 * @title IdentityCoordinator
 * @dev Coordinates identity service providers.
 * Identity providers subscribe to `IdentityVerificationRequested` events and provide their
 * services, writing the results on-chain.
 */
contract IdentityCoordinator is NeedsAbacus {
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
     * @dev Mapping of user address => requestId => existence.
     * Ensures no duplicate requests were sent.
     */
    mapping (address => mapping (uint256 => bool)) requestIds;

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
        uint256 requestId
    ) external returns (bool)
    {
        address owner = providerRegistry.providerOwner(providerId);
        if (!kernel.transferTokensFrom(msg.sender, owner, cost)) {
            return false;
        }
        // Ensure that the request id is "unique"
        if (requestIds[msg.sender][requestId]) {
            return false;
        }
        IdentityVerificationRequested(
            providerId,
            providerRegistry.latestProviderVersion(providerId),
            msg.sender,
            args,
            cost,
            requestId
        );
        requestIds[msg.sender][requestId] = true;
        return true;
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
        if (!requestIds[msg.sender][requestId]) {
            return false;
        }
        IdentityVerificationPerformed(
            providerId,
            user,
            requestId
        );
    }

}
