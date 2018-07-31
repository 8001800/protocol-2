pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "../../protocol/coordinator/ComplianceCoordinator.sol";
import "../compliance/AbacusCheck.sol";

/**
 * @dev An ERC20 token that uses Abacus for compliance.
 */
contract AbacusERC20Token is StandardToken, AbacusCheck {

    constructor(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) AbacusCheck(
        _complianceCoordinator,
        _complianceProviderId
    ) public {}

    function transfer(address to, uint256 value) public returns (bool) {
        uint256 checkResult = check(value, msg.sender, to, 0);
        if (checkResult != 0) {
            return false;
        }
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        uint256 checkResult = check(value, from, to, 0);
        if (checkResult != 0) {
            return false;
        }
        return super.transferFrom(from, to, value);
    }
}
