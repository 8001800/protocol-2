pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "../provider/Upgradable.sol";

contract IdentityProvider is Upgradable {
    function getBoolField(address user, string field) view external returns (bool);

    function getInt256Field(address user, string field) view external returns (int256);

    function getUint256Field(address user, string field) view external returns (uint256);

    function getFixedField(address user, string field) view external returns (fixed);

    function getUfixedField(address user, string field) view external returns (ufixed);

    function getAddressField(address user, string field) view external returns (address);

    function getBytes32Field(address user, string field) view external returns (bytes32);

    function getBytesField(address user, string field) view external returns (bytes);

    function getStringField(address user, string field) view external returns (string);
}