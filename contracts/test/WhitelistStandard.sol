pragma solidity ^0.4.21;

import "../library/compliance/ComplianceStandard.sol";

/**
 * @dev A compliance standard that ensures everyone is on a whitelist.
 */
contract WhitelistStandard is ComplianceStandard {

    mapping (address => bool) allowed;

    uint8 constant E_UNWHITELISTED = 1;
    uint256 operations = 0;
    uint256 delegateProviderId;

    function WhitelistStandard(
        ProviderRegistry _providerRegistry, uint256 _providerId, uint256 _delegateProviderId
    ) Provider(_providerRegistry, _providerId) public
    {
        delegateProviderId = _delegateProviderId;
        allowed[msg.sender] = true;
    }

    function allow(address user) external returns (bool) {
        allowed[user] = true;
    }

    function performCheck(
        address,
        uint256,
        address from,
        address to,
        bytes32 
  ) view external returns (uint8, uint256)
    {
        if (allowed[from] && allowed[to]) {
            return (0, delegateProviderId);
        } else {
            return (E_UNWHITELISTED, 0);
        }
    }

    function performHardCheck(
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