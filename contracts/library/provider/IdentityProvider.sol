pragma solidity ^0.4.24;

import "../../protocol/IdentityToken.sol";
import "../../protocol/AbacusKernel.sol";
import "./AsyncProvider.sol";

contract IdentityProvider is AsyncProvider {
    IdentityToken identityToken;
    AnnotationDatabase annotationDatabase;

    constructor(
        IdentityToken _identityToken,
        AbacusKernel _kernel,
        uint256 _providerId
    ) AsyncProvider(_kernel, _providerId) public
    {
        identityToken = _identityToken;
        annotationDatabase = _identityToken.annotationDatabase();
    }

    function writeBytes32Field(
        address tokenAddr,
        uint256 tokenId,
        uint256 fieldId,
        bytes32 value
    ) public onlyRole("admin") {
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
    ) public onlyRole("admin") {
        annotationDatabase.writeBytesField(
            tokenAddr,
            tokenId,
            providerId,
            fieldId,
            value
        );
    }

    function writeIdentityBytes32Field(
        address user,
        uint256 fieldId,
        bytes32 value
    ) public onlyRole("admin") {
        writeBytes32Field(
            identityToken,
            identityToken.tokenOf(user),
            fieldId,
            value
        );
    }

    function writeIdentityBytesField(
        address user,
        uint256 fieldId,
        bytes value
    ) public onlyRole("admin") {
        writeBytesField(
            identityToken,
            identityToken.tokenOf(user),
            fieldId,
            value
        );
    }
}
