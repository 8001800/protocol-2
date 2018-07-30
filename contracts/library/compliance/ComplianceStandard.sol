pragma solidity ^0.4.24;

import "../provider/Provider.sol";

/**
 * @title ComplianceStandard
 * @dev An on-chain Compliance Provider.
 */
contract ComplianceStandard is Provider {
    /**
    * @dev Performs a compliance check.
    *
    * @param instrumentAddr The address of the instrument contract.
    * @param instrumentIdOrAmt The instrument id (NFT) or amount (ERC20).
    * @param from The from address of the token transfer.
    * @param to The to address of the token transfer.
    * @param data Any additional data related to the action.
    *
    * @return an error code, 0 if no error.
    */
    function performCheck(
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data
    ) external returns (uint256);
}
