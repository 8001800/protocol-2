pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "zeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol";

interface IBundle {
    function erc20Assets(uint256 _bundleId, address _token) external returns (uint256);
    function erc721Assets(uint256 _bundleId, address _token, uint256 _tokenId) external returns (bool);
    function locked(uint256 _bundleId) external returns (bool);
    function complianceProviderIds(uint256 _bundleId) external returns (uint256);

    event Create(uint256 indexed bundleId, address owner);
    event DepositERC20(uint256 indexed bundleId, address token, uint256 amount);
    event WithdrawERC20(uint256 indexed bundleId, address token, uint256 amount);
    event DepositERC721(uint256 indexed bundleId, address token, uint256 id);
    event WithdrawERC721(uint256 indexed bundleId, address token, uint256 id);
    event Lock(uint256 indexed bundleId);
    event Unlock(uint256 indexed bundleId);

    /**
     * @dev Creates a new Bundle that one may send tokens to.
     */
    function create(string _uri, uint256 _complianceProviderId) external returns (uint256);

    /**
     * @dev Allows one to inject ERC-20 assets into the Bundle.
     */
    function depositERC20Asset(
        uint256 _bundleId, ERC20 _token, uint256 _amount
    ) external returns (bool);

    /**
     * @dev Allows the bundle owner to withdraw ERC-20 tokens from the Bundle.
     */
    function withdrawERC20Asset(
        uint256 _bundleId, ERC20 _token, uint256 _amount
    ) external returns (bool);

    /**
     * @dev Allows one to inject ERC-721 assets into the Bundle.
     */
    function depositERC721Asset(
        uint256 _bundleId, ERC721Basic _token, uint256 _id
    ) external returns (bool);

    /**
     * @dev Allows the bundle owner to withdraw ERC-721 tokens from the Bundle.
     */
    function withdrawERC721Asset(
        uint256 _bundleId, ERC721Basic _token, uint256 _id
    ) external returns (bool);

    /**
     * @dev Prevents assets from being added to the Bundle.
     */
    function lock(
        uint256 _bundleId
    ) external returns (bool);

    /**
     * @dev Allows assets to be added to the Bundle.
     */
    function unlock(
        uint256 _bundleId
    ) external returns (bool);

}