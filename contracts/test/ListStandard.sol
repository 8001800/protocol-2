pragma solidity ^0.4.19;

import "../compliance/ComplianceStandard.sol";

/**
 * @dev A compliance standard that ensures everyone is on a list.
 */
contract ListStandard is ComplianceStandard {

  mapping (address => bool) allowed;

  uint8 constant E_UNACCREDITED = 1;
  uint256 operations = 0;

  function ListStandard(
    ProviderRegistry _providerRegistry, uint256 _providerId
  ) Provider(_providerRegistry, _providerId) public
  {
  }

  function allow(address user) external returns (bool) {
    allowed[user] = true;
  }

  function check(
    address instrumentAddr,
    uint256 instrumentIdOrAmt,
    address from,
    address to,
    bytes32 data
  ) view external returns (uint8, uint256)
  {
    if (allowed[from] && allowed[to]) {
      return (0, 0);
    } else {
      return (E_UNACCREDITED, 0);
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