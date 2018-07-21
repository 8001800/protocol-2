pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/rbac/RBAC.sol";
import "../../protocol/ProviderRegistry.sol";

/**
 * @title Provider
 * @dev A contract which can be used as a provider in a ProviderRegistry.
 */
contract Provider is RBAC {
    uint256 public providerId;
    ProviderRegistry providerRegistry;
    
    /**
     * @dev Constructor used for upgrades.
     *
     * @param _providerId The provider id. If set to 0, the provider can be registered.
     */
    constructor(
        ProviderRegistry _providerRegistry, 
        uint256 _providerId       
    ) public 
    {
        providerRegistry = _providerRegistry;
        providerId = _providerId;
        addRole(msg.sender, "admin");
    }

    /**
     * @dev Registers this provider with the ProviderRegistry.
     */
    function registerProvider(
        string name,
        string metadata,
        bool isAsync
    ) onlyRole("admin") external returns (uint256)
    {
        // First, check if the provider id has been already set.
        if (providerId != 0) {
            return 0;
        }
        providerId = providerRegistry.registerProvider(
            name,
            metadata,
            this,
            isAsync
        );
        return providerId;
    }

    /**
     * @dev Upgrades this provider to a new address.
     *
     * @param nextMetadata The metadata of the next provider.
     * @param nextProvider The address of the next provider.
     * @return True if the upgrade was successful.
     */
    function performUpgrade(
        string nextMetadata, address nextProvider, bool nextIsAsync
    ) onlyRole("admin") external returns (bool)
    {
        return providerRegistry.upgradeProvider(
            providerId, nextMetadata, nextProvider, nextIsAsync
        );
    }

    /**
     * @dev Add a new admin to this provider
     *
     * @param newAdmin The address of the new admin
     */

    function addAdmin(
        address newAdmin
    ) onlyRole("admin") external 
    {
        addRole(newAdmin, "admin");
    }

    /**
     * @dev Remove an admin to this provider
     *
     * @param admin The address of the admin to be removed
     */
    function removeAdmin(
        address admin
    ) onlyRole("admin") external 
    {
        removeRole(admin, "admin");
    }
}
