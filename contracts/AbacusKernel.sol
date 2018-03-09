pragma solidity ^0.4.19;

import "./compliance/AsyncComplianceStandard.sol";

contract AbacusKernel {
  struct ComplianceSignal {
    address instrumentAddr;
    uint256 instrumentId;
  }
  mapping (address => mapping (uint256 => ComplianceSignal)) complianceSignals;

  /**
   * Initiates a compliance check.
   *
   * @param complianceStandardAddr Address of the compliance standard to use.
   * @param instrumentId Unique identifier for the instrument.
   * @param action The identifier of the action checked.
   */
  function requestComplianceCheck(
    address complianceStandardAddr,
    uint256 instrumentId,
    uint8 action
  ) external
  {
    AsyncComplianceStandard(complianceStandardAddr).requestCheck(msg.sender, instrumentId, action);
  }

  function initiateAppraisal(
    address appraisalService,
    address abacusInstrument,
    uint256 instrumentId
  ) external returns (uint256 signalId);

}