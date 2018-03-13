pragma solidity ^0.4.19;

import "../lib/ProviderRegistry.sol";

contract IdentityDatabase is ProviderRegistry {

    mapping (address => mapping(uint256 => bool)) trustMatrix;

    /**
     * Writes that msg.sender trusts a provider.
     */
    function trustProvider(uint256 providerId, bool trust) external {
        trustMatrix[msg.sender][providerId] = trust;
    }

    function addField(
        address target,
        string version,
        string key,
        string value
    ) external returns (bool);

    function getField(
        address target,
        string version,
        string key
    ) external returns (string);

}