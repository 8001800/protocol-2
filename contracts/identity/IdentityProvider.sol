pragma solidity ^0.4.19;

import "../provider/Provider.sol";
import "../identity/IdentityCoordinator.sol";

contract IdentityProvider is Provider {
    IdentityCoordinator identityCoordinator;

    function IdentityProvider(
        IdentityCoordinator _identityCoordinator,
        uint256 providerId
    ) Provider(identityCoordinator.providerRegistry(), providerId) public
    {
        identityCoordinator = _identityCoordinator;
    }

    function getBoolField(address user, uint256 fieldId) view external returns (bool);

    function getInt256Field(address user, uint256 fieldId) view external returns (int256);

    function getUint256Field(address user, uint256 fieldId) view external returns (uint256);

    function getFixedField(address user, uint256 fieldId) view external returns (fixed);

    function getUfixedField(address user, uint256 fieldId) view external returns (ufixed);

    function getAddressField(address user, uint256 fieldId) view external returns (address);

    function getBytes32Field(address user, uint256 fieldId) view external returns (bytes32);

    function getBytesField(address user, uint256 fieldId) view external returns (bytes);

    function getStringField(address user, uint256 fieldId) view external returns (string);
}
