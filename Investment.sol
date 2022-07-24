// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "./Lender.sol";
import "./Portfolio.sol";

contract Investment is Portfolio{
    Info investmentInfo;

    Lender lender;

    constructor(Info memory _investmentInfo, Lender _lender) {
        investmentInfo=_investmentInfo;
        lender=_lender;
        initTime = block.timestamp;
    }

    function getAmount() public view override returns (uint256){
        return investmentInfo.amount;
    }

    function getFinalAmount() public view override returns (uint256){
        uint256 finalAmount;
        uint r = investmentInfo.interestRate;
        uint256 p = investmentInfo.amount;
        uint n = (block.timestamp-initTime)/investmentInfo.period;
        finalAmount = p*((1+r/100)**n);
        return finalAmount;
    }


}