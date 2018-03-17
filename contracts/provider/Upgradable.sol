pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "../provider/ProviderRegistry.sol";

/**
 * @title Upgradable
 * @dev A contract which can be upgraded in a ProviderRegistry.
 */
contract Upgradable is Ownable {

    /**
     * @dev Upgrades this provider to a new address.
     *
     * @param providerRegistry The registry on which to enact the upgrade.
     * @param nextMetadata The metadata of the next provider.
     * @param nextProvider The address of the next provider.
     * @return True if the upgrade was successful.
     */
    function performUpgrade(
        ProviderRegistry providerRegistry, string nextMetadata, address nextProvider
    ) onlyOwner external returns (bool)
    {
        return providerRegistry.upgradeProvider(nextMetadata, nextProvider);
    }

}