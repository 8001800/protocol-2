pragma solidity ^0.4.19;

import "../identity/IdentityProvider.sol";
import "../compliance/ComplianceStandard.sol";

contract BooleanIdentityComplianceStandard is ComplianceStandard {
    uint256 constant public FIELD_PASSES = 0x198254;

  uint8 constant E_UNWHITELISTED = 1;
  uint256 operations = 0;
  uint256 identityProviderId;

  function BooleanIdentityComplianceStandard(
    ProviderRegistry _providerRegistry, uint256 _providerId, uint256 _identityProviderId
  ) Provider(_providerRegistry, _providerId) public
  {
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
    IdentityProvider ip = IdentityProvider(providerRegistry.providerOwner(identityProviderId));
    if (ip.getBoolField(from, FIELD_PASSES) && ip.getBoolField(to, FIELD_PASSES)) {
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