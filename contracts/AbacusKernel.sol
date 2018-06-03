pragma solidity ^0.4.21;

import "./AbacusToken.sol";
import "./provider/ProviderRegistry.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title AbacusKernel
 * @dev Manages payment with all registries. This exists to reduce friction in payment--
 * one only needs to grant the kernel allowance rather than several registries.
 */
contract AbacusKernel {
    using SafeMath for uint256;

    AbacusToken public token;
    ProviderRegistry public providerRegistry;

    address public complianceCoordinator;
    mapping (address => bool) coordinators;

    function AbacusKernel(
        AbacusToken _token,
        ProviderRegistry _providerRegistry,
        address _complianceCoordinator
    ) public
    {
        token = _token;
        providerRegistry = _providerRegistry;
        complianceCoordinator = _complianceCoordinator;
        coordinators[complianceCoordinator] = true;
    }

    /**
     * @dev Information needed to facilitate Escrow
     * The Escrow lifecycle has three steps:
     * - open: an escrow account is created between two parties
     */

    enum EscrowState {
        OPEN,
        LOCKED,
        CLOSED,
        CANCELED,
        EXPIRED
    }

    struct Escrow {
        address from;
        address to;
        uint256 amount;
        uint256 blockExpiresAt;
        EscrowState state;
    }

    /**
     * @dev Mapping of escrow id -> escrow.
     */
    mapping (uint256 => Escrow) escrows;

    /**
     * @dev The next id for an escrow.
     */
    uint256 nextEscrowId;

    /**
     * @dev Opens an escrow account between two parties.
     */
    function openEscrow(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256 escrowId)
    {
        require(from != address(0) || to != address(0));

        // Transfer tokens to kernel
        require(token.transferFrom(from, this, amount));

        escrowId = nextEscrowId++;
        escrows[escrowId] = Escrow({
            from: from,
            to: to,
            amount: amount,
            blockExpiresAt: 0,
            state: EscrowState.OPEN
        });
    }

    /**
     * @dev Locks ABA in escrow account
     */
    function lockEscrow(
        uint256 escrowId,
        uint256 blocksToExpiry
    ) internal {
        Escrow storage escrow = escrows[escrowId];
        require(escrow.state == EscrowState.OPEN);

        escrow.state = EscrowState.LOCKED;
        escrow.blockExpiresAt = blocksToExpiry.add(block.number);
    }

    /**
     * @dev Closes escrow account and transfers ABA to appropriate party
     */
    function closeEscrow(
        uint256 escrowId
    ) internal {
        Escrow storage escrow = escrows[escrowId];
        require(escrow.state == EscrowState.LOCKED);
        require(escrow.blockExpiresAt >= block.number);

        require(token.transfer(escrow.to, escrow.amount));
        escrow.state = EscrowState.CLOSED;
    }

    /**
     * @dev Revokes an escrow agreement, either due to cancellation or expiry
     */
    function revokeEscrow(
        uint256 escrowId
    ) internal {
        Escrow storage escrow = escrows[escrowId];
        require(escrow.state == EscrowState.OPEN || escrow.blockExpiresAt >= block.number);
        require(token.transfer(escrow.from, escrow.amount));
        escrow.state = escrow.state == EscrowState.OPEN ? EscrowState.CANCELED : EscrowState.EXPIRED;
    }

    /**
     * @dev Transfers ABA from an approved person to another.
     */
    function transferTokensFrom(
        address from,
        address to,
        uint256 cost
    ) public returns (bool)
    {
        require(coordinators[msg.sender] || msg.sender == from);
        return token.transferFrom(from, to, cost);
    }

    event ServiceRequested(
        uint256 indexed providerId,
        uint256 providerVersion,
        address requester,
        uint256 cost,
        uint256 requestId
    );

    event ServicePerformed(
        uint256 indexed providerId,
        address requester,
        uint256 requestId
    );

    /**
    * @dev Mapping of requester address => request id => existence.
     */
    mapping (address => mapping (uint256 => bool)) requests;

    /**
     * @dev Requests a service from the given service provider.
     */
    function requestAsyncService(
        uint256 providerId,
        uint256 cost,
        uint256 requestId
    ) external {
        address owner = providerRegistry.providerOwner(providerId);

        // Ensure that the request id is new
        require(!requests[msg.sender][requestId]);

        // Transfer tokens to the owner of the service.
        // Must be called by the requester of the service.
        require(transferTokensFrom(msg.sender, owner, cost));

        requests[msg.sender][requestId] = true;

        emit ServiceRequested({
            providerId: providerId,
            providerVersion: providerRegistry.latestProviderVersion(providerId),
            requester: msg.sender,
            cost: cost,
            requestId: requestId
        });
    }

    /**
      * @dev Called by the provider when it completes its service.
      *
      * @param providerId The provider id.
      * @param requester The address of the requester.
      * @param requestId An arbitrary id to link the request to the off-chain database.
      */
    function onAsyncServiceCompleted(
        uint256 providerId,
        address requester,
        uint256 requestId
    ) external {
        // Must be called from the service provider or by a coordinator.
        require(
            coordinators[msg.sender] ||
            msg.sender == providerRegistry.providerOwner(providerId)
        );
        require(requests[requester][requestId]);

        emit ServicePerformed({
            providerId: providerId,
            requester: requester,
            requestId: requestId
        });
    }

}