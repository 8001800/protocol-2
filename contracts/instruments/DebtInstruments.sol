pragma solidity ^0.4.19;

import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'zeppelin-solidity/contracts/token/ERC721/ERC721.sol';
import './AppraisalInstrument.sol';
import './ComplianceInstrument.sol';

contract DebtInstrument is AppraisalInstrument, ComplianceInstrument {}

contract FungibleDebtInstrument is DebtInstrument, ERC20 {}
contract NonFungibleDebtInstrument is DebtInstrument, ERC721 {}