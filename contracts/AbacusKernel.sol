pragma solidity ^0.4.19;

import "./compliance/ComplianceRegistry.sol";

contract AbacusKernel {
  ComplianceRegistry complianceRegistry;

  function Abacus(
    address _complianceRegistry
  ) public
  {
    complianceRegistry = ComplianceRegistry(_complianceRegistry);
  }

  struct ComplianceSignal {
    address instrumentAddr;
    uint256 instrumentId;
  }
  mapping (address => mapping (uint256 => ComplianceSignal)) complianceSignals;

  /**
   * Initiates a compliance check.
   *
   * @param serviceId Id of the compliance service to use.
   * @param instrumentId Unique identifier for the instrument.
   * @param action The identifier of the action checked.
   */
  function requestComplianceCheck(
    uint256 serviceId,
    uint256 instrumentId,
    uint8 action
  ) external
  {
    // uint256 cost = complianceRegistry.cost(serviceId);
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