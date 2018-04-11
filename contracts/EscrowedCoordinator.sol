pragma solidity ^0.4.21;

import "./AbacusCoordinator.sol";
import "./provider/ProviderRegistry.sol";

contract EscrowedCoordinator is AbacusCoordinator {
    ProviderRegistry public providerRegistry;

    function EscrowedCoordinator(ProviderRegistry _providerRegistry) public  {
        providerRegistry = _providerRegistry;
    }

    event ServiceRequested(
        uint256 indexed providerId,
        uint256 providerVersion,
        uint256 cost,
        uint256 requestId
    );

    event ServicePerformed(
        uint256 indexed providerId,
        address requester,
        uint256 requestId
    );

    /**
     * @dev Mapping of user address => requestId => escrow.
     */
    mapping (address => mapping (uint256 => uint256)) requestEscrows;

    function requestService(
        uint256 providerId,
        uint256 cost,
        uint256 requestId,
        uint256 expiryBlocks
    ) external {
        address owner = providerRegistry.providerOwner(providerId);

        // Ensure that the request id is new
        require(requestEscrows[msg.sender][requestId] == 0);

        // Create escrow
        uint256 escrowId = kernel.beginEscrow(msg.sender, owner, cost, expiryBlocks);
        require(escrowId != 0);
        requestEscrows[msg.sender][requestId] = escrowId;
        emit IdentityVerificationRequested(
            providerId,
            providerRegistry.latestProviderVersion(providerId),
            msg.sender,
            cost,
            requestId
        );
    }

    function lockEscrow(
        uint256 providerId,
        address user,
        uint256 requestId,
        uint256 expiryBlocks
    ) external returns (bool)
    {
        // Ensure requester is the provider owner
        require(msg.sender == providerRegistry.providerOwner(providerId));
        // Ensure request exists
        uint256 escrowId = requestEscrows[user][requestId];
        require(escrowId != 0);
        // redeem kernel escrow
        return kernel.lockEscrow(escrowId, expiryBlocks);
    }

    function revokeVerification(uint256 requestId) external returns (bool) {
        uint256 escrowId = requestEscrows[msg.sender][requestId];
        require(escrowId != 0);
        return kernel.revokeEscrow(escrowId);
    }

    /**
     * @dev Called by the coordinator when a provider completes its service.
     *
     * @param providerId The provider id.
     * @param requester The address of the requester.
     * @param requestId An arbitrary id to link the request to the off-chain database.
     */
    function onServiceCompleted(
        uint256 providerId,
        address requester,
        uint256 requestId
    ) external {
        // Ensure requester is the provider owner
        require(msg.sender != providerRegistry.providerOwner(providerId));
        // Ensure request exists
        uint256 escrowId = requestEscrows[requester][requestId];
        require(escrowId != 0);
        // redeem kernel escrow
        require(kernel.redeemEscrow(escrowId));

        emit ServicePerformed({
            providerId: providerId,
            requester: requester,
            requestId: requestId
        });
    }

}