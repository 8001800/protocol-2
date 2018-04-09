pragma solidity ^0.4.21;

import "../identity/IdentityDatabase.sol";
import "../compliance/ComplianceStandard.sol";

contract UintSandboxComplianceStandard is ComplianceStandard {
  IdentityDatabase identityDatabase;
  uint8 constant E_UNWHITELISTED = 1;
  uint256 operations = 0;
  uint256 identityProviderId;
  uint256 constant public FIELD_NUM = 888;

  function UintSandboxComplianceStandard(
    IdentityDatabase _identityDatabase,
    ProviderRegistry _providerRegistry,
    uint256 _providerId,
    uint256 _identityProviderId
  ) Provider(_providerRegistry, _providerId) public
  {
    identityDatabase = _identityDatabase;
    identityProviderId = _identityProviderId;
  }

  function check(
    address,
    uint256,
    address from,
    address to,
    bytes32 
 ) view external returns (uint8, uint256)
  {
    uint256 fromVal = uint256(identityDatabase.bytes32Data(identityProviderId, from, FIELD_NUM));
    uint256 toVal = uint256(identityDatabase.bytes32Data(identityProviderId, to, FIELD_NUM));
    if (fromVal > 10 && toVal > 10) {
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