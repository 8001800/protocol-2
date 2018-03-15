pragma solidity ^0.4.19;

import "./AbacusToken.sol";
import "./compliance/ComplianceRegistry.sol";

contract AbacusKernel {
  AbacusToken public token;
  ComplianceRegistry public complianceRegistry;

  function AbacusKernel(
    address _token,
    address _complianceRegistry
  ) public
  {
    token = AbacusToken(_token);
    complianceRegistry = ComplianceRegistry(_complianceRegistry);
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
    complianceRegistry.requestCheck(providerId, msg.sender, actionId);
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

}