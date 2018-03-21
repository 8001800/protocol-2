pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "../compliance/ComplianceCoordinator.sol";
import "./AbacusInstrument.sol";

/**
 * @dev An ERC20 token that uses Abacus for compliance.
 */
contract AbacusERC20Token is StandardToken, AbacusInstrument {
    ComplianceCoordinator complianceCoordinator;
    uint256 complianceProviderId;

    function transfer(address to, uint256 value) public returns (bool) {
        if (complianceCoordinator.check(complianceProviderId, this, value, msg.sender, to, 0) != 0) {
            return false;
        }
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        if (complianceCoordinator.check(complianceProviderId, this, value, from, to, 0) != 0) {
            return false;
        }
        return super.transferFrom(from, to, value);
    }
}
