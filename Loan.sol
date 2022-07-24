// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "./Borrower.sol";
import "./Bank.sol";

contract Loan {
    struct LoanInfo {
        uint loanID;
        uint256 amount;
        uint timeToPay;
        uint period;
        uint interestRate;
    }
    LoanInfo loanInfo;

    uint256 finalAmount;
    uint initTime;
    // uint256 periodicalPayment;

    uint256 collateral;
    bool collateralDeposited;

    enum Status {
        approved,
        rejected
    }
    Status status;

    Borrower borrower;
    address bank;

    constructor(LoanInfo memory _loanInfo, Borrower _borrower) {
        loanInfo=_loanInfo;
        borrower=_borrower;
        bank = msg.sender; 
        initTime=block.timestamp;
        
        uint p = _loanInfo.amount;
        uint r = _loanInfo.interestRate;
        uint n = _loanInfo.timeToPay/_loanInfo.period;
        finalAmount = p*((1+(r/100))**n);
    }
    
    modifier onlyBank() {
        require(msg.sender==bank);
        _;
    }


    function getLoanAmount() public view returns(uint256){
        return loanInfo.amount;
    }

    function approveLoan() onlyBank public {
        status=Status.approved;
    }

    function rejectLoan() onlyBank public {
        status=Status.rejected;
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

    function getStatus() public view returns(bool){
        if (status==Status.approved){
            return true;
        } else {
            return false;
        }
    }   


    // function getPeriodicalPayment() public view returns(uint256){
    //     return periodicalPayment;
    // }


    function getFinalAmount() public view returns(uint256){
        return finalAmount;
    }

    function getInitTime() public view returns(uint){
        return initTime;
    }

    function updateFinalAmount(uint256 amount) public onlyBank returns(uint256){
        finalAmount -= amount;
        return finalAmount;
    }

}

//updates to loan upon emi payments
//not paid loan -> actions

// add functionality for higher payments than annuity to clear loans quicker