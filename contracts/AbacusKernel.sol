pragma solidity ^0.4.19;

import "./AbacusToken.sol";
import "./compliance/ComplianceRegistry.sol";
import "./identity/IdentityDatabase.sol";

/**
 * @title AbacusKernel
 * @dev Manages payment with all registries. This exists to reduce friction in payment--
 * one only needs to grant the kernel allowance rather than several registries.
 */
contract AbacusKernel {
  AbacusToken public token;
  ComplianceRegistry public complianceRegistry;
  IdentityDatabase public identityDatabase;

  function AbacusKernel(
    AbacusToken _token,
    ComplianceRegistry _complianceRegistry,
    IdentityDatabase _identityDatabase
  ) public
  {
    token = _token;
    complianceRegistry = _complianceRegistry;
    identityDatabase = _identityDatabase;
  }

  /**
   * Initiates an async (off-chain) compliance check.
   *
   * @param providerId Id of the compliance provider to use.
   */
  function requestComplianceCheck(
    address requester,
    uint256 providerId,
    uint256 instrumentIdOrAmt,
    address from,
    address to,
    bytes32 data,
    uint256 cost
  ) external returns (bool)
  {
    address owner = complianceRegistry.providerOwner(providerId);
    if (!token.transferFrom(requester, owner, cost)) {
      return false;
    }
    complianceRegistry.requestCheck(
      providerId,
      msg.sender,
      instrumentIdOrAmt,
      from,
      to,
      data,
      cost
    );
    return true;
  }

  /**
   * Initiates an identity verification request.
   *
   * @param providerId Id of the identity provider to use.
   */
  function requestIdentity(
    uint256 providerId,
    string args,
    uint256 cost,
    uint256 requestToken
  ) external returns (bool)
  {
    address owner = identityDatabase.providerOwner(providerId);
    if (!token.transferFrom(msg.sender, owner, cost)) {
      return false;
    }
    identityDatabase.requestVerification(providerId, msg.sender, args, cost, requestToken);
    return true;
  }

}