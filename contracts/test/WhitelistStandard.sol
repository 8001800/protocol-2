pragma solidity ^0.4.19;

import "../compliance/ComplianceStandard.sol";

/**
 * @dev A compliance standard that ensures everyone is on a whitelist.
 */
contract WhitelistStandard is ComplianceStandard {

  mapping (address => bool) allowed;

  uint8 constant E_UNWHITELISTED = 1;
  uint256 operations = 0;

  function WhitelistStandard(
    ProviderRegistry _providerRegistry, uint256 _providerId
  ) Provider(_providerRegistry, _providerId) public
  {
    allowed[msg.sender] = true;
  }

  function allow(address user) external returns (bool) {
    allowed[user] = true;
  }

  function check(
    address,
    uint256,
    address from,
    address to,
    bytes32 
 ) view external returns (uint8, uint256)
  {
    if (allowed[from] && allowed[to]) {
      return (0, 0);
    } else {
      return (E_UNWHITELISTED, 0);
    }
  }

  function onHardCheck(
    address,
    uint256,
    address,
    address,
    bytes32
  ) external
  {
    operations++;
  }
}