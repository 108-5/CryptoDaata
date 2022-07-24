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

    function getCollateralRequirement(Loan _loan)public view returns(uint256) {
        uint256 collateral = ((collateralPercentage * _loan.getAmount()) / 100);
        return collateral;
    }

    function approveLoan(Loan _loan) public returns(bool) {
        // check whether bank has enough funds to sanction loan
        require(getFunds() > _loan.getCollateral(), "Insufficient funds to sanction loan");
        _loan.setStatus(true);
        return _loan.getStatus();
        //emit sanction loan

    }

    function payUser(User _user,uint256 amount) public returns(bool) {
        require(getFunds() > amount, "Insufficient funds");
        (bool sent, bytes memory data) = address(_user).call{value: amount}("");
        // require(sent, "Failed to send Ether");
        return sent;
    }


    

    function sanctionLoan(Loan _loan,bool _collateralDeposited,bytes memory paymentData,Borrower _borrower) public {
        
        verifyPayment(_collateralDeposited,paymentData);
        _loan.setCollateralStatus();
        uint256 loanAmount = _loan.getAmount();
        bool paymentStatus = payUser(_borrower,loanAmount);
        if(paymentStatus==false){
            //Pay back collateral
            uint256 collateral = _loan.getCollateral();
            payUser(_borrower,collateral);
        }
        collateralReserve+=_loan.getCollateral();
        loans[_borrower] = _loan;
    }

    function verifyPayment(bool received, bytes memory paymentData) public {
        require(received,"Payment not received");
        // require(paymentData check something here,"");
    }

    function updateLoan(Borrower _borrower,Loan _loan,bool _receivedPayment,bytes memory paymentData,uint256 amount) public {
        verifyPayment(_receivedPayment,paymentData);
        uint256 finalAmount = _loan.updateFinalAmount(amount);
        if (finalAmount==0){
            //Loan paid, so return collateral
            uint256 collateral = _loan.getCollateral();
            payUser(_borrower,collateral);

        }
    }

    function redeemInvestment(Lender _lender,Investment _investment) public {
        uint256 finalAmount = _investment.getFinalAmount();
        bool paymentStatus = payUser(_lender,finalAmount);
        require(paymentStatus, "Failed to send Ether");
    }

//add functionality to approve loans only if funds > investment returns
// shift from collateral reserve to funds when loan period ends

// periodic payments from borrower
// withdraw function for lender
// implement time
}