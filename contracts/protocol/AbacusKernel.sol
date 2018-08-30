pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

import "./ProviderRegistry.sol";

/**
 * @title AbacusKernel
 * @dev Manages payment with all registries. This exists to reduce friction in payment--
 * one only needs to grant the kernel allowance rather than several registries.
 */
contract AbacusKernel {
    using SafeMath for uint256;

    StandardToken public token;
    ProviderRegistry public providerRegistry;

    constructor(
        StandardToken _token,
        ProviderRegistry _providerRegistry
    ) public
    {
        token = _token;
        providerRegistry = _providerRegistry;
    }

    /**
     * @dev Information needed to facilitate Escrow
     * The Escrow lifecycle has three steps:
     * - open: escrow account is created with tokens
     * - lock: locks tokens in an escrow account
     * And either one of the following:
     * - close: closes an escrow account and distributes tokens to the appropriate party
     * - revoke: revokes an escrow account if requester cancels or wants to retrieve tokens on expiry
     */

    enum EscrowState {
        OPEN,
        LOCKED,
        CLOSED,
        REVOKED_CANCEL,
        REVOKED_EXPIRY
    }

    struct Escrow {
        EscrowState state;
        address from;
        address to;
        uint256 amount;
        uint256 expiryBlockInterval;
        uint256 blockLocked;
    }

    /**
     * @dev Mapping of escrow id -> escrow.
     */
    mapping (uint256 => Escrow) public escrows;

    /**
     * @dev The next id for an escrow.
     */
    uint256 nextEscrowId = 1;

    /**
     * @dev Opens an escrow account between two parties.
     */
    function openEscrow(
        address from,
        address to,
        uint256 amount,
        uint256 expiryBlockInterval
    ) internal returns (uint256 escrowId)
    {
        require(from != address(0) && to != address(0) && to != address(this));

        // Transfer tokens to kernel
        require(token.transferFrom(from, this, amount));

        escrowId = nextEscrowId.add(1);
        escrows[escrowId] = Escrow({
            state: EscrowState.OPEN,
            from: from,
            to: to,
            amount: amount,
            expiryBlockInterval: expiryBlockInterval,
            blockLocked: 0
        });
    }

    /**
     * @dev Locks ABA in escrow account
     */
    function lockEscrow(
        uint256 escrowId
    ) internal {
        Escrow storage escrow = escrows[escrowId];
        require(escrow.state == EscrowState.OPEN);

        escrow.state = EscrowState.LOCKED;
        escrow.blockLocked = block.number;
    }

    /**
     * @dev Closes escrow account and transfers ABA to appropriate party
     */
    function closeEscrow(
        uint256 escrowId
    ) internal {
        Escrow storage escrow = escrows[escrowId];
        require(escrow.state == EscrowState.LOCKED);
        require(block.number < escrow.blockLocked.add(escrow.expiryBlockInterval));

        require(token.transfer(escrow.to, escrow.amount));
        escrow.state = EscrowState.CLOSED;
    }

    /**
     * @dev Revokes an escrow agreement, either due to cancellation or expiry
     */
    function revokeEscrow(
        uint256 escrowId
    ) internal returns (EscrowState) {
        Escrow storage escrow = escrows[escrowId];
        require(
            escrow.state == EscrowState.OPEN ||
            //check if service request expired
            block.number >= escrow.blockLocked.add(escrow.expiryBlockInterval));
        require(token.transfer(escrow.from, escrow.amount));
        escrow.state = escrow.state == EscrowState.OPEN ? EscrowState.REVOKED_CANCEL : EscrowState.REVOKED_EXPIRY;
        return escrow.state;
    }

    event ServiceRequested(
        uint256 indexed providerId,
        uint256 providerVersion,
        uint256 escrowId,
        address requester,
        uint256 cost,
        uint256 requestId
    );

    event ServiceRequestAccepted(
        uint256 indexed providerId,
        uint256 escrowId,
        address requester,
        uint256 requestId
    );

    event ServiceRequestRevokedByCancel(
        address requester,
        uint256 indexed requestId
    );

    event ServiceRequestRevokedByExpiry(
        address requester,
        uint256 indexed requestId
    );

    event ServicePerformed(
        uint256 indexed providerId,
        uint256 escrowId,
        address requester,
        uint256 requestId
    );

    /**
     * @dev Mapping of requester address => request id => escrow id.
     */
    mapping (address => mapping (uint256 => uint256)) requests;

    /**
     * @dev Requests a service from the given service provider.
     */
    function requestAsyncService(
        uint256 providerId,
        uint256 cost,
        uint256 requestId,
        uint256 expiryBlockInterval
    ) external {
        address owner = providerRegistry.providerOwner(providerId);

        // Ensure that the request id is new
        require(requests[msg.sender][requestId] == 0);
        // Open and record escrow account
        uint256 escrowId = openEscrow(msg.sender, owner, cost, expiryBlockInterval);
        requests[msg.sender][requestId] = escrowId;

        emit ServiceRequested({
            providerId: providerId,
            providerVersion: providerRegistry.latestProviderVersion(providerId),
            escrowId: escrowId,
            requester: msg.sender,
            cost: cost,
            requestId: requestId
        });
    }

    /**
     * @dev Locks escrow account for an Async Service Request
     */
    function acceptAsyncServiceRequest(
        uint256 providerId,
        address requester,
        uint256 requestId
    ) external {
        // Ensure request exists
        uint256 escrowId = requests[requester][requestId];
        require(escrowId != 0);

        // Only the owner of the provider can accept requests
        require(msg.sender == providerRegistry.providerOwner(providerId));

        lockEscrow(escrowId);

        emit ServiceRequestAccepted({
            providerId: providerId,
            escrowId: escrowId,
            requester: requester,
            requestId: requestId
        });
    }

    /**
     * @dev Revokes an Async Service Request. This will only succeed if escrow account is open or expired.
     */
    function revokeAsyncServiceRequest(
        uint256 requestId
    ) external {
        uint256 escrowId = requests[msg.sender][requestId];
        require(escrowId != 0);
        EscrowState state = revokeEscrow(escrowId);

        if (state == EscrowState.REVOKED_CANCEL)
            emit ServiceRequestRevokedByCancel(msg.sender, requestId);
        else
            emit ServiceRequestRevokedByExpiry(msg.sender, requestId);
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
        // Must be called from the service provider.
        require(msg.sender == providerRegistry.providerOwner(providerId));

        uint256 escrowId = requests[requester][requestId];
        require(escrowId != 0);

        closeEscrow(escrowId);

        emit ServicePerformed({
            providerId: providerId,
            escrowId: escrowId,
            requester: requester,
            requestId: requestId
        });
    }

}