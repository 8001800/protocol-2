pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./Provider.sol";
import "../../protocol/ProviderRegistry.sol";
import "../../protocol/AnnotationDatabase.sol";

/**
 * @title Provider
 * @dev A contract which can be used as a provider in a ProviderRegistry.
 */
contract AsyncProvider is Provider {
    AnnotationDatabase annotationDatabase;

    /**
     * @dev Constructor can also be used for upgrades.
     *
     * @param _providerId The provider id. If set to 0, the provider can be registered.
     */
    constructor(
        ProviderRegistry _providerRegistry,
        AnnotationDatabase _annotationDatabase,
        uint256 _providerId     
    ) Provider(_providerRegistry, _providerId) public
    {
        annotationDatabase = _annotationDatabase;
    }

    function writeBytes32Field(
        address tokenAddr,
        uint256 tokenId,
        uint256 fieldId,
        bytes32 value
    ) public onlyAdmin {
        annotationDatabase.writeBytes32Field(
            tokenAddr,
            tokenId,
            providerId,
            fieldId,
            value
        );
    }

    function writeBytesField(
        address tokenAddr,
        uint256 tokenId,
        uint256 fieldId,
        bytes value
    ) public onlyAdmin {
        annotationDatabase.writeBytesField(
            tokenAddr,
            tokenId,
            providerId,
            fieldId,
            value
        );
    }
}
