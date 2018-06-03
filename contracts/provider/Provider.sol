pragma solidity ^0.4.21;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../provider/ProviderRegistry.sol";

/**
 * @title Provider
 * @dev A contract which can be used as a provider in a ProviderRegistry.
 */
contract Provider is Ownable {
    uint256 public providerId;
    ProviderRegistry providerRegistry;

    /**
     * @dev Constructor used for upgrades.
     *
     * @param _providerId The provider id. If set to 0, the provider can be registered.
     */
    function Provider(ProviderRegistry _providerRegistry, uint256 _providerId) public {
        providerRegistry = _providerRegistry;
        providerId = _providerId;
    }

    /**
     * @dev Registers this provider with the ProviderRegistry.
     */
    function registerProvider(
        string name,
        string metadata,
        bool isAsync
    ) onlyOwner external returns (uint256)
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
    ) onlyOwner external returns (bool)
    {
        return providerRegistry.upgradeProvider(
            providerId, nextMetadata, nextProvider, nextIsAsync
        );
    }

}
