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

  function checkCompliance(
    uint256 providerId,
    address instrumentAddr,
    uint256 instrumentIdOrAmt,
    address from,
    address to,
    bytes32 data
  ) external returns (uint8, uint256)
  {
    return complianceRegistry.hardCheck(
      providerId,
      instrumentAddr,
      instrumentIdOrAmt,
      from,
      to,
      data
    );
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