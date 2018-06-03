pragma solidity ^0.4.21;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "../compliance/ComplianceCoordinator.sol";
import "./AbacusInstrument.sol";

/**
 * @dev An ERC20 token that uses Abacus for compliance.
 */
contract AbacusERC20Token is StandardToken, AbacusInstrument {
    ComplianceCoordinator complianceCoordinator;
    uint256 complianceProviderId;

    function AbacusERC20Token(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) public
    {
        complianceCoordinator = _complianceCoordinator;
        complianceProviderId = _complianceProviderId;
    }

    function canTransfer(address to, uint256 value) public view returns (uint8, uint256) {
        return complianceCoordinator.check(complianceProviderId, this, value, msg.sender, to, 0);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        uint8 checkResult;
        (checkResult,) = complianceCoordinator.hardCheck(complianceProviderId, this, value, msg.sender, to, 0);
        if (checkResult != 0) {
            return false;
        }
        return super.transfer(to, value);
    }

    function canTransferFrom(address from, address to, uint256 value) public view returns (uint8, uint256) {
        return complianceCoordinator.check(complianceProviderId, this, value, from, to, 0);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        uint8 checkResult;
        (checkResult,) = complianceCoordinator.hardCheck(complianceProviderId, this, value, from, to, 0);
        if (checkResult != 0) {
            return false;
        }
        return super.transferFrom(from, to, value);
    }
}
