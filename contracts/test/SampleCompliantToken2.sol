pragma solidity ^0.4.21;

import "./FaucetToken.sol";

/**
 * @dev A very simple token that implements a single compliance standard.
 */
contract SampleCompliantToken2 is FaucetToken {
    string public constant name = "Sample Compliant Token 2";
    string public constant symbol = "SC2";

    function SampleCompliantToken2(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) FaucetToken(_complianceCoordinator, _complianceProviderId) public
    {
    }
}