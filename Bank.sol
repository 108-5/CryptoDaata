// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "./Lender.sol";
import "./Borrower.sol";
import "./Loan.sol";
import "./User.sol";
import "./Investment.sol";

//different banks can have varying interests and collateral percentages

contract Bank {
    
    receive() external payable {}
    fallback() external payable {}

    mapping(Borrower => Loan) loans;
    mapping(Lender => Investment) investments;

    uint interest;
    uint collateralPercentage;

    uint256 collateralReserve;

    constructor(uint _interest, uint _collateralPercentage) {
        interest = _interest;
        collateralPercentage = _collateralPercentage;
    }


    function getFunds() public view returns(uint256){
        return address(this).balance;
    }

    function getInvestmentInfo(Lender _lender) public view returns (Investment){
        return investments[_lender];
    }


    function getLoanInfo(Borrower _borrower) public view returns (Loan){
        return loans[_borrower];
    }

    // function applyLoan(Loan _loan) public {
    //     // bool loanStatus = processLoan(_loan, msg.sender);
    //     // require(loanStatus,"Failed to process loan");
    //     require(getFunds() > _loan.getLoanAmount,"Insufficient funds in bank");
    //     uint256 collateral = getCollateralRequirement(_loan);
    //     return collateral;
    //     // sanctionLoan(_loan,msg.sender);

    // }

    // function processLoan(Loan _loan, Borrower,_borrower) public returns(bool){
    //     uint256 collateral = address(_borrower).balance;
    //     if (address(_borrower).balance > collateral) {
    //         _loan.approveLoan;
    //     } else {
    //         _loan.rejectLoan;
    //     }
    //     return _loan.getStatus();
    // }

    function getCollateralRequirement(Loan _loan)public view returns(uint256) {
        uint256 collateral = ((collateralPercentage * _loan.getLoanAmount()) / 100);
        return collateral;
    }

    function approveLoan(Loan _loan) public returns(bool) {
        // check whether bank has enough funds to sanction loan
        require(getFunds() > _loan.getCollateral(), "Insufficient funds to sanction loan");
        _loan.approveLoan();
        return _loan.getStatus();
        //emit sanction loan

    }

    function verifyCollateralDeposit(Loan _loan, bool received, bytes memory paymentData) public {
        require(received,"Collateral not received");
        // require(paymentData check something here,"");
        _loan.setCollateralStatus();
    }

    function payBorrower(Loan _loan,Borrower _borrower) public {
        if(getFunds()>_loan.getLoanAmount()) {
            (bool sent, bytes memory data) = address(_borrower).call{value: _loan.getLoanAmount()}("");
            require(sent, "Failed to send Ether");
        }
        else{
            (bool sent, bytes memory data) = address(_borrower).call{value: _loan.getCollateral()}("");
            require(sent, "Failed to send Ether");
            collateralReserve-=_loan.getCollateral();
        }
    }

    function sanctionLoan(Loan _loan,bool _collateralDeposited,bytes memory paymentData,Borrower _borrower) public {
        verifyCollateralDeposit(_loan,_collateralDeposited,paymentData);
        bool collateralStatus = _loan.getCollateralStatus();
        require(collateralStatus,"Collateral not deposited");
        collateralReserve+=_loan.getCollateral();
        loans[_borrower] = _loan;
        payBorrower(_loan,_borrower);
    }

//add functionality to approve loans only if funds > investment returns
// shift from collateral reserve to funds when loan period ends

// periodic payments from borrower
// withdraw function for lender
// implement time
}