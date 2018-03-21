pragma solidity ^0.4.19;

import "./AbacusToken.sol";

/**
 * @title AbacusKernel
 * @dev Manages payment with all registries. This exists to reduce friction in payment--
 * one only needs to grant the kernel allowance rather than several registries.
 */
contract AbacusKernel {
  AbacusToken public token;
  address public complianceCoordinator;
  address public identityCoordinator;
  address public providerRegistry;

  mapping (address => bool) coordinators;

  function AbacusKernel(
    AbacusToken _token,
    address _complianceCoordinator,
    address _identityCoordinator,
    address _providerRegistry
  ) public
  {
    token = _token;
    complianceCoordinator = _complianceCoordinator;
    identityCoordinator = _identityCoordinator;
    providerRegistry = _providerRegistry;

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