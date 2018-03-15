pragma solidity ^0.4.19;

import "../provider/ProviderRegistry.sol";

contract IdentityDatabase is ProviderRegistry {

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