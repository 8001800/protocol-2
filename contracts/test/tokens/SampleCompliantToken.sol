pragma solidity ^0.4.24;

import "./BaseTestToken.sol";

/**
 * @dev A token that requires being on a whitelist.
 */
contract SampleCompliantToken is BaseTestToken {
    string public constant name = "Sample Compliant Token";
    string public constant symbol = "SCT";

    constructor(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) BaseTestToken(_complianceCoordinator, _complianceProviderId) public
    {
    }
}