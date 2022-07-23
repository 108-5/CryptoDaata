// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "./Lender.sol";

contract Investment {
    struct InvestmentInfo {
        uint investmentID;
        uint256 amount;
    }
    InvestmentInfo investmentInfo;
    Lender lender;
    constructor(InvestmentInfo memory _investmentInfo, Lender _lender) {
        investmentInfo=_investmentInfo;
        lender=_lender;
    }
    function getInvestmentAmount() public view returns (uint256){
        return investmentInfo.amount;
    }
}