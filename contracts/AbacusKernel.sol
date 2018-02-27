pragma solidity ^0.4.19;

contract AbacusKernel {

  function initiateComplianceCheck(
    address complianceStandard,
    address abacusInstrument,
    uint256 instrumentId
  ) external returns (uint256 signalId);

  function initiateAppraisal(
    address appraisalService,
    address abacusInstrument,
    uint256 instrumentId
  ) external returns (uint256 signalId);

}