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
   * @param serviceId Id of the compliance service to use.
   * @param actionId The identifier of the action checked.
   */
  function requestComplianceCheck(
    address requester,
    uint256 serviceId,
    uint256 actionId,
    uint256 cost
  ) external returns (bool)
  {
    address owner = complianceRegistry.serviceOwner(serviceId);
    if (!token.transferFrom(requester, owner, cost)) {
      return false;
    }
    complianceRegistry.requestCheck(serviceId, msg.sender, actionId);
    return true;
  }

  function checkCompliance(
    uint256 serviceId,
    address instrumentAddr,
    uint256 actionId
  ) external returns (uint8, uint256)
  {
    return complianceRegistry.check(serviceId, instrumentAddr, actionId);
  }

}