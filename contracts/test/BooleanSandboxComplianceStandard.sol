pragma solidity ^0.4.21;

import "../identity/IdentityDatabase.sol";
import "../compliance/ComplianceStandard.sol";

contract BooleanSandboxComplianceStandard is ComplianceStandard {
  IdentityDatabase identityDatabase;
  uint8 constant E_UNWHITELISTED = 1;
  uint256 operations = 0;
  uint256 identityProviderId;
  uint256 constant public FIELD_NUM = 88;

  function BooleanSandboxComplianceStandard(
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
    bool fromPasses = identityDatabase.bytes32Data(identityProviderId, from, FIELD_NUM) != bytes32(0);
    bool toPasses = identityDatabase.bytes32Data(identityProviderId, to, FIELD_NUM) != bytes32(0);
    if (fromPasses && toPasses) {
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