pragma solidity ^0.4.21;

import "./FaucetToken.sol";

/**
 * @dev A very simple token that implements a single compliance standard.
 */
contract SampleCompliantToken3 is FaucetToken {
    string public constant name = "Sample Compliant Token 3";
    string public constant symbol = "SC3";

    function SampleCompliantToken3(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) FaucetToken(_complianceCoordinator, _complianceProviderId) public
    {
    }
}