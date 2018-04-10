pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol";
import "zeppelin-solidity/contracts/token/ERC721/ERC721BasicToken.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @dev A collection of ERC20 and ERC721 assets represented as an ERC721 token.
 */
contract Basket is ERC721BasicToken {
    using SafeMath for uint256;
    uint256 public totalSupply;

    mapping (uint256 => mapping (address => uint256)) erc20Assets;
    mapping (uint256 => mapping (address => mapping (uint256 => bool))) erc721Assets;

    event BasketCreate(uint256 basketId, address owner);
    event BasketDepositERC20(uint256 basketId, address token, uint256 amount);
    event BasketWithdrawERC20(uint256 basketId, address token, uint256 amount);
    event BasketDepositERC721(uint256 basketId, address token, uint256 id);
    event BasketWithdrawERC721(uint256 basketId, address token, uint256 id);

    function create() external returns (uint256) {
        uint256 id = ++totalSupply;
        _mint(msg.sender, id);
        emit BasketCreate(id, msg.sender);
    }

    function depositERC20Asset(
        uint256 _basketId, ERC20 _token, uint256 _amount
    ) external returns (bool) {
        if (!_token.transferFrom(msg.sender, this, _amount)) {
            return false;
        }
        erc20Assets[_basketId][_token] = erc20Assets[_basketId][_token].add(_amount);
        emit BasketDepositERC20(_basketId, _token, _amount);
        return true;
    }

    function withdrawERC20Asset(
        uint256 _basketId, ERC20 _token, uint256 _amount
    ) external returns (bool) {
        if (msg.sender != ownerOf(_basketId)) {
            return false;
        }
        if (!_token.transfer(msg.sender, _amount)) {
            return false;
        }
        erc20Assets[_basketId][_token] = erc20Assets[_basketId][_token].sub(_amount);
        emit BasketWithdrawERC20(_basketId, _token, _amount);
        return true;
    }

    function depositERC721Asset(
        uint256 _basketId, ERC721Basic _token, uint256 _id
    ) external returns (bool) {
        _token.transferFrom(msg.sender, this, _id);
        erc721Assets[_basketId][_token][_id] = true;
        emit BasketDepositERC721(_basketId, _token, _id);
        return true;
    }

    function withdrawERC721Asset(
        uint256 _basketId, ERC721Basic _token, uint256 _id
    ) external returns (bool) {
        if (msg.sender != ownerOf(_basketId)) {
            return false;
        }
        if (!erc721Assets[_basketId][_token][_id]) {
            return false;
        }
        _token.safeTransferFrom(this, msg.sender, _id);
        erc721Assets[_basketId][_token][_id] = false;
        emit BasketWithdrawERC721(_basketId, _token, _id);
        return true;
    }

}