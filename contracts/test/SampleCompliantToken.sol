pragma solidity ^0.4.24;

import "./FaucetToken.sol";

/**
 * @dev A very simple token that implements a single compliance standard.
 */
contract SampleCompliantToken is FaucetToken {
    string public constant name = "Sample Compliant Token";
    string public constant symbol = "SC1";

    constructor(
        ComplianceCoordinator _complianceCoordinator,
        uint56 _complianceProviderId
    ) FaucetToken(_complianceCoordinator, _complianceProviderId) public
    {
    }
}