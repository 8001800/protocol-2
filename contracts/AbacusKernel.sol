pragma solidity ^0.4.19;

import "./AbacusToken.sol";
import "./compliance/ComplianceRegistry.sol";

contract AbacusKernel {
  AbacusToken token;
  ComplianceRegistry complianceRegistry;

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
   * @param instrumentId Unique identifier for the instrument.
   * @param action The identifier of the action checked.
   */
  function requestComplianceCheck(
    address requester,
    uint256 serviceId,
    uint256 instrumentId,
    uint8 action
  ) external
  {
    uint256 cost;
    address owner;
    (cost, owner) = complianceRegistry.paymentDetails(serviceId);
    require(token.transferFrom(requester, owner, cost));
    complianceRegistry.requestCheck(serviceId, msg.sender, instrumentId, action);
  }

  function checkCompliance(
    uint256 serviceId,
    address instrumentAddr,
    uint256 instrumentId,
    uint256 action
  ) external returns (uint8)
  {
    return complianceRegistry.check(serviceId, instrumentAddr, instrumentId, action);
  }

  function initiateAppraisal(
    address appraisalService,
    address abacusInstrument,
    uint256 instrumentId
  ) external returns (uint256 signalId);

}