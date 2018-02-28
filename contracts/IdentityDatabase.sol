pragma solidity ^0.4.19;

contract IdentityDatabase {

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