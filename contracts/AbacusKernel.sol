pragma solidity ^0.4.21;

import "./AbacusToken.sol";

/**
 * @title AbacusKernel
 * @dev Manages payment with all registries. This exists to reduce friction in payment--
 * one only needs to grant the kernel allowance rather than several registries.
 */
contract AbacusKernel {
  AbacusToken public token;
  address public providerRegistry;

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
    address _providerRegistry,

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
    uint256 cost,
    uint256 blocksToExpiry
  ) external returns (uint256)
  {
    // Only the coordinator should be able to call this
    if (!coordinators[msg.sender]) {
      return 0;
    }

    // Transfer tokens to the escrow
    if (!token.transferFrom(from, this, cost)) {
      return 0;
    }

    uint256 escrowId = nextEscrowId++;
    escrows[escrowId] = Escrow({
      from: from,
      to: to,
      cost: cost,
      locked: false,
      blockExpiresAt: blocksToExpiry + block.number
    });
    return escrowId;
  }

  /**
   * @dev Puts a hold on the escrow so the initiator cannot take the payment back.
   */
  function lockEscrow(
    uint256 escrowId,
    uint256 blocksToExpiry
  ) external returns (bool) {
    // Only the coordinator should be able to call this
    if (!coordinators[msg.sender]) {
      return false;
    }

    Escrow storage escrow = escrows[escrowId];
    if (escrow.locked || escrow.blockExpiresAt <= block.number) {
      return false;
    }

    // If not, lock it and reset expiry
    escrow.locked = true;
    escrow.blockExpiresAt = blocksToExpiry + block.number;
    return true;
  }

  /**
   * @dev Allows the receiver to withdraw the escrow payment.
   */
  function redeemEscrow(uint256 escrowId) external returns (bool) {
    // Only the coordinator should be able to call this
    if (!coordinators[msg.sender]) {
      return false;
    }

    Escrow storage escrow = escrows[escrowId];
    if (!escrow.locked || escrow.blockExpiresAt <= block.number) {
      return false;
    }

    // redeem the escrow
    if (!token.transfer(escrow.to, escrow.cost)) {
      return false;
    }

    // forcefully expire the escrow
    escrow.blockExpiresAt = 0;
    return true;
  }

    /**
    * @dev Gets the escrow payment back to the initiator if the escrow was not
    * fulfilled.
    */
    function revokeEscrow(uint256 escrowId) external returns (bool) {
        // Only the coordinator should be able to call this
        if (!coordinators[msg.sender]) {
            return false;
        }

        Escrow storage escrow = escrows[escrowId];
        // don't allow revoke if escrow is locked and unexpired
        if (escrow.locked && escrow.blockExpiresAt > block.number) {
            return false;
        }

        // revoke the escrow
        if (!token.transfer(escrow.from, escrow.cost)) {
            return false;
        }

        // forcefully expire the escrow
        escrow.blockExpiresAt = 0;
        return true;
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
        uint256 escrowId = beginEscrow(msg.sender, owner, cost, expiryBlocks);
        require(escrowId != 0);
        requestEscrows[msg.sender][requestId] = escrowId;
        emit ServiceRequested({
            providerId: providerId,
            providerVersion: providerRegistry.latestProviderVersion(providerId),
            requester: msg.sender,
            cost: cost,
            requestId: requestId
        });
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
        return lockEscrow(escrowId, expiryBlocks);
    }

    function revokeVerification(uint256 requestId) external returns (bool) {
        uint256 escrowId = requestEscrows[msg.sender][requestId];
        require(escrowId != 0);
        return revokeEscrow(escrowId);
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
    ) internal {
        require(coordinators[msg.sender]);
        // Ensure requester is the provider owner
        require(msg.sender != providerRegistry.providerOwner(providerId));
        // Ensure request exists
        uint256 escrowId = requestEscrows[requester][requestId];
        require(escrowId != 0);
        // redeem kernel escrow
        require(redeemEscrow(escrowId));

        emit ServicePerformed({
            providerId: providerId,
            requester: requester,
            requestId: requestId
        });
    }

}