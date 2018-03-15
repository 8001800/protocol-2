pragma solidity ^0.4.19;

import "./AbacusToken.sol";
import "./compliance/ComplianceRegistry.sol";
import "./identity/IdentityDatabase.sol";

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

  struct ComplianceSignal {
    address instrumentAddr;
    uint256 instrumentId;
  }
  mapping (address => mapping (uint256 => ComplianceSignal)) complianceSignals;

  /**
   * Initiates an async (off-chain) compliance check.
   *
   * @param providerId Id of the compliance provider to use.
   * @param actionId The identifier of the action checked.
   */
  function requestComplianceCheck(
    address requester,
    uint256 providerId,
    uint256 actionId,
    uint256 cost
  ) external returns (bool)
  {
    address owner = complianceRegistry.providerOwner(providerId);
    if (!token.transferFrom(requester, owner, cost)) {
      return false;
    }
    complianceRegistry.requestCheck(providerId, msg.sender, actionId, cost);
    return true;
  }

  function checkCompliance(
    uint256 providerId,
    address instrumentAddr,
    uint256 actionId
  ) external returns (uint8, uint256)
  {
    return complianceRegistry.hardCheck(providerId, instrumentAddr, actionId);
  }

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