pragma solidity ^0.4.21;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Provider.sol";
import "../../protocol/ProviderRegistry.sol";
import "../../protocol/AbacusToken.sol";
import "../../protocol/AbacusKernel.sol";

/**
 * @title Provider
 * @dev A contract which can be used as a provider in a ProviderRegistry.
 */
contract AsyncProvider is Provider {
    AbacusKernel kernel;
    AbacusToken public token;
    
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
    ) Provider (_providerRegistry, _providerId) public 
    {
        providerRegistry = _providerRegistry;
        kernel = _kernel;
        token = _token;
        providerId = _providerId;
    }

    /**
     * @dev Withdraw ABA balance from smart contract
     *
     * @param value Amount of ABA to withdraw 
     */
    function withdrawBalance(
        uint256 value
    ) onlyOwner public returns (uint256)
    {
        require(value <= token.balanceOf(this));
        token.transfer(msg.sender, value);
        return value;
    }

    /**
     * @dev Signal the kernel to accept async service requests and open escrow
     * 
     * @param requester Ethereum address of the service requester
     * @param requestId Request ID of the service request 
     */

     function acceptServiceRequest(
         address requester,
         uint256 requestId
     ) onlyOwner public returns (uint256)
     {
         kernel.acceptAsyncServiceRequest(providerId, requester, requestId);
         return requestId;
     }

     /**
      * @dev Signal the kernel that service was completed and close escrow
      *
      * @param requester Ethereum address of the service requester
      * @param requestId Request ID of the service request 
      */
      function completeServiceRequest(
          address requester,
          uint256 requestId
      ) onlyOwner public returns (uint256)
      {
          kernel.onAsyncServiceCompleted(providerId, requester, requestId);
          return requestId;
      }

}
