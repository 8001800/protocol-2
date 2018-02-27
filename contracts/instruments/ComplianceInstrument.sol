pragma solidity ^0.4.19;

import './AbacusInstrument.sol';

contract ComplianceInstrument is AbacusInstrument {

  /**
    * Compliance Requests
    */

  function requestComplianceCheck(uint256 id)
    external returns (uint256 signalId);

  function requestComplianceCheck(uint256 id, uint256 complianceServiceId)
    external returns (uint256 signalId);

  function requestComplianceCheck(uint256 id, address complianceStandard)
    external returns (uint256 signalId);


  /**
    * Compliance Callback
    */

  function onComplianceCheckFinished(uint256 signalId, bool isCompliant) external;

}