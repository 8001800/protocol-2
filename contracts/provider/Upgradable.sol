pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "../provider/ProviderRegistry.sol";

contract Upgradable is Ownable {

    /**
     * Upgrades this provider to a new address.
     */
    function performUpgrade(
        ProviderRegistry providerRegistry, string nextMetadata, address nextProvider
    ) onlyOwner external returns (bool)
    {
        return providerRegistry.upgradeProvider(nextMetadata, nextProvider);
    }

}