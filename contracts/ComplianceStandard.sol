pragma solidity ^0.4.19;

interface ComplianceStandard {

  function check(address abacusInstrument, uint256 instrumentId) external;

}