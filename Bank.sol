// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "./Lender.sol";
import "./Borrower.sol";
import "./Loan.sol";
import "./User.sol";
import "./Investment.sol";

//different banks can have varying interests and collateral percentages

contract Bank {
    
    mapping(Borrower => Loan) loans;
    mapping(Lender => Investment) investments;

    event CompletedPayment(bool _sent);
    event CollateralReturned(address _from, address _to);
    event LoanSanctioned(address _from, address _to);
    event LoanPaidOff();
    event PaymentReceived(address _from, uint256 _amount);

    




    uint interest;
    uint collateralPercentage;

    uint256 collateralReserve;

    constructor (uint _interest, uint _collateralPercentage) payable {
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

        emit CompletedPayment(sent);
        return sent;
    }


    

    function sanctionLoan(Loan _loan,Borrower _borrower) public {
        
        _loan.setCollateralStatus();
        uint256 loanAmount = _loan.getAmount();
        bool paymentStatus = payUser(_borrower,loanAmount);
        if(paymentStatus==false){
            //Pay back collateral
            uint256 collateral = _loan.getCollateral();
            payUser(_borrower,collateral);
            emit CollateralReturned(address(this),address(_borrower));
        } else {
            emit LoanSanctioned(address(this),address(_borrower));
        }
        collateralReserve+=_loan.getCollateral();
        loans[_borrower] = _loan;
    }

    
    function updateLoan(Borrower _borrower,Loan _loan,uint256 amount) public {
        uint256 finalAmount = _loan.updateFinalAmount(amount);
        if (finalAmount==0){
            //Loan paid, so return collateral
            uint256 collateral = _loan.getCollateral();
            payUser(_borrower,collateral);
            emit LoanPaidOff();
        }
    }

    function redeemInvestment(Lender _lender,Investment _investment) public {
        uint256 finalAmount = _investment.getFinalAmount();
        bool paymentStatus = payUser(_lender,finalAmount);
        require(paymentStatus, "Failed to send Ether");
    }



    receive() external payable {
        emit PaymentReceived(msg.sender,msg.value);
    }
    fallback() external payable {}

// shift from collateral reserve to funds when loan period ends

// periodic payments from borrower
}