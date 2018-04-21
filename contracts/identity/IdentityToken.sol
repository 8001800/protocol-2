pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol";
import "../AnnotationDatabase.sol";

/**
 * @title IdentityToken
 * @dev Tokenized representation of identity. The AnnotationDatabase stores data related
 * to this token.
 */
contract IdentityToken is ERC721Basic {
    AnnotationDatabase public annotationDatabase;

    function IdentityToken(AnnotationDatabase _annotationDatabase) public
    {
        annotationDatabase = _annotationDatabase;
    }

    function readBytes32Data(
        address _user,
        uint256 _providerId,
        uint256 _fieldId
    ) external view returns (uint256, bytes32)
    {
        return annotationDatabase.bytes32Data(
            this,
            tokenOf(_user),
            _providerId,
            _fieldId
        );
    }

    function tokenOf(address _owner) public view returns (uint256) {
        return uint256(_owner);
    }

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return 1;
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return address(_tokenId);
    }

    function exists(uint256 _tokenId) public view returns (bool _exists) {
        return true;
    }

    function approve(address _to, uint256 _tokenId) public {
        revert();
    }

    function getApproved(uint256 _tokenId) public view returns (address _operator) {
        return address(0);
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        revert();
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return false;
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        revert();
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {
        revert();
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    ) public {
        revert();
    }


}
