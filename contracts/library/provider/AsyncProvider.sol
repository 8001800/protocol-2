pragma solidity ^0.4.21;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../../protocol/ProviderRegistry.sol";
import "../../protocol/AbacusToken.sol";
import "../../protocol/AbacusKernel.sol";

/**
 * @title Provider
 * @dev A contract which can be used as a provider in a ProviderRegistry.
 */
contract AsyncProvider is Ownable {
    ProviderRegistry providerRegistry;
    AbacusKernel kernel;
    AbacusToken public token;
    uint256 public providerId;
    
    /**
     * @dev Constructor used for upgrades.
     *
     * @param _providerId The provider id. If set to 0, the provider can be registered.
     */
    function AsyncProvider(
        ProviderRegistry _providerRegistry, 
        AbacusKernel _kernel,
        AbacusToken _token,
        uint256 _providerId       
    ) public 
    {
        providerRegistry = _providerRegistry;
        kernel = _kernel;
        token = _token;
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

    /**
     * @dev Withdraw ABA balance from smart contract
     *
     * @param value Amount of ABA to withdraw 
     */
    function withdrawBalance(
        uint256 value
    ) onlyOwner external returns (uint256)
    {
        require(value <= token.balanceOf(this));
        token.transfer(msg.sender, value);
        return value;
    }

    /**
     * @dev Accept async service requests and open escrow
     * 
     *  @param requester Ethereum address of the service requester
     *  @param requestId Request ID of the service request 
     */

     function acceptServiceRequest(
         address requester,
         uint256 requestId
     ) onlyOwner external returns (uint256)
     {
         kernel.acceptAsyncServiceRequest(providerId, requester, requestId);
         return requestId;
     }

}
