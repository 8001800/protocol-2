pragma solidity ^0.4.19;

interface DebtInstrument {

  /**
    * Service Requests
    */

  function requestComplianceCheck(uint256 id)
    external returns (uint256 signalId);

  function requestComplianceCheck(uint256 id, uint256 complianceServiceId)
    external returns (uint256 signalId);

  function requestComplianceCheck(uint256 id, address complianceStandard)
    external returns (uint256 signalId);

  function requestAppraisal(uint256 id)
    external returns (uint256 signalId);

  function requestAppraisal(uint256 id, address appraisalService)
    external returns (uint256 signalId);

  /**
    * Service Callbacks
    */
  
  function onComplianceCheckFinished(uint256 signalId, bool isCompliant) external;

  function onAppraisalFinished(uint256 signalId, uint256 value, uint256 decimals) external;

  /**
    * Getters for Debt Token information.
    * This allows ComplianceStandards to query information about
    * a debt instrument without needing to know how its data is structured.
    */

  function getBoolField(uint256 id, string field) external returns (bool);

  function getInt256Field(uint256 id, string field) external returns (int256);

  function getUint256Field(uint256 id, string field) external returns (uint256);

  function getFixedField(uint256 id, string field) external returns (fixed);

  function getUfixedField(uint256 id, string field) external returns (ufixed);

  function getAddressField(uint256 id, string field) external returns (address);

  function getBytes32Field(uint256 id, string field) external returns (bytes32);

  function getBytesField(uint256 id, string field) external returns (bytes);

  function getStringField(uint256 id, string field) external returns (string);

}