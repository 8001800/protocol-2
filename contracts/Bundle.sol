pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "./compliance/ComplianceCoordinator.sol";
import "./IBundle.sol";

/**
 * @dev A collection of ERC20 and ERC721 assets represented as an ERC721 token.
 * Bundles are initialized in an unlocked state. Transfer of Bundles may only
 * occur when the Bundle is locked. When a Bundle is unlocked, transfer is forbidden.
 */
contract Bundle is ERC721Token, IBundle {
    using SafeMath for uint256;

    uint256 nextTokenId = 1;

    mapping (uint256 => mapping (address => uint256)) public erc20Assets;
    mapping (uint256 => mapping (address => mapping (uint256 => bool))) public erc721Assets;
    mapping (uint256 => bool) public locked;
    mapping (uint256 => uint256) public complianceProviderIds;

    ComplianceCoordinator complianceCoordinator;

    function Bundle(
        ComplianceCoordinator _complianceCoordinator
    ) public ERC721Token("Bundle", "BND")
    {
        complianceCoordinator = _complianceCoordinator;
    }

    /**
     * @dev Creates a new Bundle that one may send tokens to.
     */
    function create(string _uri, uint256 _complianceProviderId) external returns (uint256) {
        uint256 id = nextTokenId++;
        _mint(msg.sender, id);
        _setTokenURI(id, _uri);
        complianceProviderIds[id] = _complianceProviderId;
        emit Create(id, msg.sender);
    }

    /**
     * @dev Allows one to inject ERC-20 assets into the Bundle.
     */
    function depositERC20Asset(
        uint256 _bundleId, ERC20 _token, uint256 _amount
    ) external returns (bool) {
        if (locked[_bundleId]) {
            return false;
        }
        if (!_token.transferFrom(msg.sender, this, _amount)) {
            return false;
        }
        erc20Assets[_bundleId][_token] = erc20Assets[_bundleId][_token].add(_amount);
        emit DepositERC20(_bundleId, _token, _amount);
        return true;
    }

    /**
     * @dev Allows the bundle owner to withdraw ERC-20 tokens from the Bundle.
     */
    function withdrawERC20Asset(
        uint256 _bundleId, ERC20 _token, uint256 _amount
    ) external returns (bool) {
        if (msg.sender != ownerOf(_bundleId)) {
            return false;
        }
        if (locked[_bundleId]) {
            return false;
        }
        if (!_token.transfer(msg.sender, _amount)) {
            return false;
        }
        erc20Assets[_bundleId][_token] = erc20Assets[_bundleId][_token].sub(_amount);
        emit WithdrawERC20(_bundleId, _token, _amount);
        return true;
    }

    /**
     * @dev Allows one to inject ERC-721 assets into the Bundle.
     */
    function depositERC721Asset(
        uint256 _bundleId, ERC721Basic _token, uint256 _id
    ) external returns (bool) {
        if (locked[_bundleId]) {
            return false;
        }
        _token.transferFrom(msg.sender, this, _id);
        erc721Assets[_bundleId][_token][_id] = true;
        emit DepositERC721(_bundleId, _token, _id);
        return true;
    }

    /**
     * @dev Allows the bundle owner to withdraw ERC-721 tokens from the Bundle.
     */
    function withdrawERC721Asset(
        uint256 _bundleId, ERC721Basic _token, uint256 _id
    ) external returns (bool) {
        if (msg.sender != ownerOf(_bundleId)) {
            return false;
        }
        if (locked[_bundleId]) {
            return false;
        }
        if (!erc721Assets[_bundleId][_token][_id]) {
            return false;
        }
        _token.safeTransferFrom(this, msg.sender, _id);
        erc721Assets[_bundleId][_token][_id] = false;
        emit WithdrawERC721(_bundleId, _token, _id);
        return true;
    }

    /**
     * @dev Prevents assets from being added to the Bundle.
     */
    function lock(
        uint256 _bundleId
    ) external returns (bool) {
        if (msg.sender != ownerOf(_bundleId)) {
            return false;
        }
        locked[_bundleId] = true;
        emit Lock(_bundleId);
        return true;
    }

    /**
     * @dev Allows assets to be added to the Bundle.
     */
    function unlock(
        uint256 _bundleId
    ) external returns (bool) {
        if (msg.sender != ownerOf(_bundleId)) {
            return false;
        }
        locked[_bundleId] = false;
        emit Unlock(_bundleId);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        require(locked[_tokenId]);
        if (complianceProviderIds[_tokenId] != 0) {
            uint8 result;
            (result,) = complianceCoordinator.hardCheck(
                complianceProviderIds[_tokenId],
                this,
                _tokenId,
                _from,
                _to,
                bytes32(0)
            );
            if (result != 0) {
                return;
            }
        }
        super.transferFrom(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {
        require(locked[_tokenId]);
        if (complianceProviderIds[_tokenId] != 0) {
            uint8 result;
            (result,) = complianceCoordinator.hardCheck(
                complianceProviderIds[_tokenId],
                this,
                _tokenId,
                _from,
                _to,
                bytes32(0)
            );
            if (result != 0) {
                return;
            }
        }
        super.safeTransferFrom(_from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    ) public {
        require(locked[_tokenId]);
        if (complianceProviderIds[_tokenId] != 0) {
            uint8 result;
            (result,) = complianceCoordinator.hardCheck(
                complianceProviderIds[_tokenId],
                this,
                _tokenId,
                _from,
                _to,
                bytes32(0)
            );
            if (result != 0) {
                return;
            }
        }
        super.safeTransferFrom(_from, _to, _tokenId, _data);
    }


}