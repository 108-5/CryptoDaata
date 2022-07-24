// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "./Borrower.sol";
import "./Bank.sol";
import "./Portfolio.sol";

contract Loan is Portfolio{
    
    // uint256 periodicalPayment;

    Info loanInfo;

    uint256 collateral;
    bool collateralDeposited;

    // false - rejected, true - approved
    bool status;
    
    event FinalAmountCalculated(uint _p, uint _r, uint _n, uint256 _finalAmount);

    Borrower borrower;

    constructor(Info memory _loanInfo, Borrower _borrower) {
        loanInfo=_loanInfo;
        borrower=_borrower;
        bank = msg.sender; 
        initTime=block.timestamp;
        
        uint p = _loanInfo.amount;
        uint r = _loanInfo.interestRate;
        uint n = _loanInfo.tenure/_loanInfo.period;
        finalAmount = p*((1+r/100)**n);
        emit FinalAmountCalculated(p,r,n,finalAmount);
    }
    
    function getAmount() public view override returns(uint256) {
        return loanInfo.amount;
    }

    function setStatus(bool _status) public {
        status=_status;
    }

    function getStatus() public view returns(bool) {
        return status;
    }

    function setCollateral(uint256 _collateral) public {
        collateral = _collateral;
    }

    function getCollateral() public view returns(uint256) {
        return collateral;
    }

    function getCollateralStatus() public view returns(bool) {
        return collateralDeposited;
    }

    function setCollateralStatus() public {
        collateralDeposited=true;
    }

    function getFinalAmount() public view override returns (uint256) {
        return finalAmount;
    }

    function updateFinalAmount(uint256 amount) public onlyBank returns(uint256){
        finalAmount -= amount;
        return finalAmount;
    }

}

//updates to loan upon emi payments
//not paid loan -> actions

// add functionality for higher payments than annuity to clear loans quicker