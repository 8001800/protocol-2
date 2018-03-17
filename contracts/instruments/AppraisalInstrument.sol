pragma solidity ^0.4.19;

import "./AbacusInstrument.sol";

contract AppraisalInstrument is AbacusInstrument {

  /**
    * Appraisal Requests
    */

  function requestAppraisal(uint256 id)
    external returns (uint256 signalId);

  function requestAppraisal(uint256 id, address appraisalService)
    external returns (uint256 signalId);

  /**
    * Appraisal Callback
    */

  function onAppraisalFinished(uint256 signalId, uint256 value, uint256 decimals) external;

}