// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "./Lender.sol";

contract Investment {
    struct InvestmentInfo {
        uint investmentID;
        uint256 amount;
        uint interestRate;
        uint period;
    }
    InvestmentInfo investmentInfo;

    uint initTime;
    Lender lender;

    constructor(InvestmentInfo memory _investmentInfo, Lender _lender) {
        investmentInfo=_investmentInfo;
        lender=_lender;
        initTime = block.timestamp;
    }

    function getInvestmentAmount() public view returns (uint256){
        return investmentInfo.amount;
    }

    function getFinalAmount() public returns (uint256){
        uint256 finalAmount;
        uint r = investmentInfo.interestRate;
        uint256 p = investmentInfo.amount;
        uint n = (block.timestamp-initTime)/investmentInfo.period;
        finalAmount = p*((1+r/100)**n);
        return finalAmount;
    }


}