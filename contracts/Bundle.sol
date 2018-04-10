pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @dev A collection of ERC20 and ERC721 assets represented as an ERC721 token.
 */
contract Bundle is ERC721Token {
    using SafeMath for uint256;

    uint256 nextTokenId = 1;

    mapping (uint256 => mapping (address => uint256)) erc20Assets;
    mapping (uint256 => mapping (address => mapping (uint256 => bool))) erc721Assets;

    event BundleCreate(uint256 indexed bundleId, address owner);
    event BundleDepositERC20(uint256 indexed bundleId, address token, uint256 amount);
    event BundleWithdrawERC20(uint256 indexed bundleId, address token, uint256 amount);
    event BundleDepositERC721(uint256 indexed bundleId, address token, uint256 id);
    event BundleWithdrawERC721(uint256 indexed bundleId, address token, uint256 id);

    function Bundle() public ERC721Token("Bundle", "BKT") {
    }

    function create(string _uri) external returns (uint256) {
        uint256 id = nextTokenId++;
        _mint(msg.sender, id);
        _setTokenURI(id, _uri);
        emit BundleCreate(id, msg.sender);
    }

    function depositERC20Asset(
        uint256 _bundleId, ERC20 _token, uint256 _amount
    ) external returns (bool) {
        if (!_token.transferFrom(msg.sender, this, _amount)) {
            return false;
        }
        erc20Assets[_bundleId][_token] = erc20Assets[_bundleId][_token].add(_amount);
        emit BundleDepositERC20(_bundleId, _token, _amount);
        return true;
    }

    function withdrawERC20Asset(
        uint256 _bundleId, ERC20 _token, uint256 _amount
    ) external returns (bool) {
        if (msg.sender != ownerOf(_bundleId)) {
            return false;
        }
        if (!_token.transfer(msg.sender, _amount)) {
            return false;
        }
        erc20Assets[_bundleId][_token] = erc20Assets[_bundleId][_token].sub(_amount);
        emit BundleWithdrawERC20(_bundleId, _token, _amount);
        return true;
    }

    function depositERC721Asset(
        uint256 _bundleId, ERC721Basic _token, uint256 _id
    ) external returns (bool) {
        _token.transferFrom(msg.sender, this, _id);
        erc721Assets[_bundleId][_token][_id] = true;
        emit BundleDepositERC721(_bundleId, _token, _id);
        return true;
    }

    function withdrawERC721Asset(
        uint256 _bundleId, ERC721Basic _token, uint256 _id
    ) external returns (bool) {
        if (msg.sender != ownerOf(_bundleId)) {
            return false;
        }
        if (!erc721Assets[_bundleId][_token][_id]) {
            return false;
        }
        _token.safeTransferFrom(this, msg.sender, _id);
        erc721Assets[_bundleId][_token][_id] = false;
        emit BundleWithdrawERC721(_bundleId, _token, _id);
        return true;
    }

}