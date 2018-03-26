pragma solidity ^0.4.19;

import "./AbacusToken.sol";

/**
 * @title AbacusKernel
 * @dev Manages payment with all registries. This exists to reduce friction in payment--
 * one only needs to grant the kernel allowance rather than several registries.
 */
contract AbacusKernel {
  AbacusToken public token;
  address public providerRegistry;

  address public complianceCoordinator;
  address public identityCoordinator;

  mapping (address => bool) coordinators;

  function AbacusKernel(
    AbacusToken _token,
    address _providerRegistry,

    address _complianceCoordinator,
    address _identityCoordinator
  ) public
  {
    token = _token;
    providerRegistry = _providerRegistry;

    complianceCoordinator = _complianceCoordinator;
    identityCoordinator = _identityCoordinator;

    coordinators[complianceCoordinator] = coordinators[identityCoordinator] = true;
  }

  /**
   * @dev Transfers ABA from an approved person to another.
   */
  function transferTokensFrom(
    address from,
    address to,
    uint256 cost
  ) external returns (bool)
  {
    if (!coordinators[msg.sender]) {
      return false;
    }
    return token.transferFrom(from, to, cost);
  }

}