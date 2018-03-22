pragma solidity ^0.4.19;

contract AbacusInstrument {

  /**
    * Getters for information.
    * This allows ComplianceStandards to query information about
    * an instrument without needing to know how its data is structured.
    */
  function getBoolField(uint256 id, string field) view external returns (bool) {
    assert(false);
  }

  function getInt256Field(uint256 id, string field) view external returns (int256) {
    assert(false);
  }

  function getUint256Field(uint256 id, string field) view external returns (uint256) {
    assert(false);
  }

  // function getFixedField(uint256 id, string field) view external returns (fixed) {
  //   assert(false);
  // }

  // function getUfixedField(uint256 id, string field) view external returns (ufixed) {
  //   assert(false);
  // }

  function getAddressField(uint256 id, string field) view external returns (address) {
    assert(false);
  }

  function getBytes32Field(uint256 id, string field) view external returns (bytes32) {
    assert(false);
  }

  function getBytesField(uint256 id, string field) view external returns (bytes) {
    assert(false);
  }

  function getStringField(uint256 id, string field) view external returns (string) {
    assert(false);
  }

}
