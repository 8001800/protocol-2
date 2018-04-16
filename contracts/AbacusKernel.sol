pragma solidity ^0.4.21;

import "./AbacusToken.sol";
import "./provider/ProviderRegistry.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

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
    address public identityCoordinator;

    mapping (address => bool) coordinators;

    struct Escrow {
        address from;
        address to;
        uint256 cost;
        bool locked;
        uint256 blockExpiresAt;
    }

    /**
    * @dev Contains mapping of escrow id to escrow.
    */
    mapping (uint256 => Escrow) escrows;

    /**
    * @dev The next id for an escrow.
    */
    uint256 nextEscrowId = 1;

    function AbacusKernel(
        AbacusToken _token,
        ProviderRegistry _providerRegistry,

        address _complianceCoordinator,
        address _identityCoordinator
    ) public
    {
        token = _token;
        providerRegistry = _providerRegistry;

        complianceCoordinator = _complianceCoordinator;
        identityCoordinator = _identityCoordinator;

        coordinators[complianceCoordinator] = coordinators[identityCoordinator] = true;
    }

    /**
    * @dev Transfers ABA from an approved person to another.
    */
    function transferTokensFrom(
        address from,
        address to,
        uint256 cost
    ) external returns (bool)
    {
        if (!coordinators[msg.sender]) {
            return false;
        }
        return token.transferFrom(from, to, cost);
    }

    /**
    * @dev Initiates an escrow of ABA between two parties.
    * The steps of a sucessful escrow are:
    * - begin (initiate escrow)
    * - lock (ensure payment will be received)
    * - redeem (retrieve payment)
    * If at any point the receiver of the payment messes up,
    * the payer may `revoke` the escrow and get their money back.
    */
    function beginEscrow(
        address from,
        address to,
        uint256 cost
    ) internal returns (uint256)
    {
        // Transfer tokens to the escrow
        require(token.transferFrom(from, this, cost));
        uint256 escrowId = nextEscrowId++;
        escrows[escrowId] = Escrow({
            from: from,
            to: to,
            cost: cost,
            locked: false,
            blockExpiresAt: 0
        });
        return escrowId;
    }

    /**
    * @dev Puts a hold on the escrow so the initiator cannot take the payment back.
    */
    function lockEscrow(
        uint256 escrowId,
        uint256 blocksToExpiry
    ) internal {
        Escrow storage escrow = escrows[escrowId];
        require(!escrow.locked);
        require(escrow.from != address(0) || escrow.to != address(0));
        escrow.locked = true;
        escrow.blockExpiresAt = blocksToExpiry.add(block.number);
    }

    /**
    * @dev Allows the receiver to withdraw the escrow payment.
    */
    function redeemEscrow(uint256 escrowId) internal {
        Escrow storage escrow = escrows[escrowId];
        require(escrow.locked);
        require(escrow.blockExpiresAt > block.number);
        // require(msg.sender == escrow.to);
        // require(token.transfer(escrow.to, escrow.cost));

        // // forcefully expire the escrow
        // escrow.blockExpiresAt = 0;
    }

    /**
    * @dev Gets the escrow payment back to the initiator if the escrow was not
    * fulfilled.
    */
    function revokeEscrow(uint256 escrowId) internal {
        Escrow storage escrow = escrows[escrowId];
        require(!escrow.locked);
        require(token.transfer(escrow.from, escrow.cost));

        // forcefully expire the escrow
        escrow.blockExpiresAt = 0;
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
    * @dev Mapping of requester address => requestId => escrow.
    */
    mapping (address => mapping (uint256 => uint256)) requestEscrows;

    /**
     * @dev Requests a service from the given service provider.
     */
    function requestService(
        uint256 providerId,
        uint256 cost,
        uint256 requestId
    ) external {
        address owner = providerRegistry.providerOwner(providerId);

        // Ensure that the request id is new
        require(requestEscrows[msg.sender][requestId] == 0);

        // Create escrow
        uint256 escrowId = beginEscrow(msg.sender, owner, cost);
        requestEscrows[msg.sender][requestId] = escrowId;
        emit ServiceRequested({
            providerId: providerId,
            providerVersion: providerRegistry.latestProviderVersion(providerId),
            requester: msg.sender,
            cost: cost,
            requestId: requestId
        });
    }

    /**
     * @dev Locks payment for a service request.
     */
    function lockRequest(
        uint256 providerId,
        address user,
        uint256 requestId,
        uint256 expiryBlocks
    ) external
    {
        // Ensure requester is the provider owner
        require(msg.sender == providerRegistry.providerOwner(providerId));
        // Ensure request exists
        uint256 escrowId = requestEscrows[user][requestId];
        require(escrowId != 0);
        // lock kernel escrow
        lockEscrow(escrowId, expiryBlocks);
    }

    /**
     * @dev Revokes a request.
     */
    function revokeRequest(uint256 requestId) external {
        uint256 escrowId = requestEscrows[msg.sender][requestId];
        require(escrowId != 0);
        revokeEscrow(escrowId);
    }

    /**
      * @dev Called by the provider when it completes its service.
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
        require(msg.sender == providerRegistry.providerOwner(providerId));
        // Ensure request exists
        uint256 escrowId = requestEscrows[requester][requestId];
        require(escrowId != 0);
        // redeem kernel escrow
        redeemEscrow(escrowId);

        emit ServicePerformed({
            providerId: providerId,
            requester: requester,
            requestId: requestId
        });
    }

}