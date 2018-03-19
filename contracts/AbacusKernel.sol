pragma solidity ^0.4.19;

import "./AbacusToken.sol";
import "./compliance/ComplianceRegistry.sol";
import "./identity/IdentityDatabase.sol";

/**
 * @title AbacusKernel
 * @dev Manages payment with all registries. This exists to reduce friction in payment--
 * one only needs to grant the kernel allowance rather than several registries.
 */
contract AbacusKernel {
  AbacusToken public token;
  ComplianceRegistry public complianceRegistry;
  IdentityDatabase public identityDatabase;
  ProviderRegistry public providerRegistry;

  mapping (address => bool) coordinators;

  function AbacusKernel(
    AbacusToken _token,
    ComplianceRegistry _complianceRegistry,
    IdentityDatabase _identityDatabase,
    ProviderRegistry _providerRegistry
  ) public
  {
    token = _token;
    complianceRegistry = _complianceRegistry;
    identityDatabase = _identityDatabase;
    providerRegistry = _providerRegistry;

    coordinators[complianceRegistry] = coordinators[identityDatabase] = true;
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