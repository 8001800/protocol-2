pragma solidity ^0.4.19;

import "../provider/Provider.sol";
import "../identity/IdentityCoordinator.sol";

contract IdentityProvider is Provider {
    IdentityCoordinator identityCoordinator;

    function IdentityProvider(
        IdentityCoordinator _identityCoordinator,
        uint256 providerId
    ) Provider(_identityCoordinator.providerRegistry(), providerId) public
    {
        identityCoordinator = _identityCoordinator;
    }

    function getBoolField(address user, uint256 fieldId) view external returns (bool) {
        assert(false);
    }

    function getInt256Field(address user, uint256 fieldId) view external returns (int256) {
        assert(false);
    }

    function getUint256Field(address user, uint256 fieldId) view external returns (uint256) {
        assert(false);
    }

    function getAddressField(address user, uint256 fieldId) view external returns (address) {
        assert(false);
    }

    function getBytes32Field(address user, uint256 fieldId) view external returns (bytes32) {
        assert(false);
    }

    function getBytesField(address user, uint256 fieldId) view external returns (bytes) {
        assert(false);
    }

    function getStringField(address user, uint256 fieldId) view external returns (string) {
        assert(false);
    }
}
