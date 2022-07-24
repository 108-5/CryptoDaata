// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "./User.sol";
import "./Loan.sol";

contract Borrower is User{
    
    UserInfo borrowerInfo;
    
    receive() external payable {
        emit PaymentReceived(msg.sender,msg.value);
    }
    fallback() external payable {}

    event CompletedPayment(bool _sent);
    event DepositedCollateral(bool _sent);
    event PaymentDetails(uint256 _amount, uint256 _finalAmount, uint256 _balance);
    event PaymentReceived(address _from, uint256 _amount);
    
    constructor(UserInfo memory _borrowerInfo) payable {
        borrowerInfo = _borrowerInfo;
        owner = payable(msg.sender);
    }

    function getCollateralRequirement(Bank _bank, Loan _loan) public returns(uint256){
        uint256 collateral = _bank.getCollateralRequirement(_loan);
        _loan.setCollateral(collateral);
        return collateral;
    }    

    function depositCollateral(Bank _bank, Loan _loan) public {
        bool approval = _bank.approveLoan(_loan);
        require(approval,"Loan Rejected");
        (bool sent, bytes memory data) = address(_bank).call{value: _loan.getCollateral()}("");
        require(sent, "Failed to send Ether");
        emit DepositedCollateral(sent);
        _bank.sanctionLoan(_loan,this);
    }

    function payLoan(Bank _bank, Loan _loan,uint256 amount) public {
        uint finalAmount = _loan.getFinalAmount();
        require(address(this).balance > finalAmount,"Insufficient Funds");
        if (amount>finalAmount){
            amount = finalAmount;
        }
        emit PaymentDetails(amount,finalAmount,address(this).balance);
        (bool sent, bytes memory data) = address(_bank).call{value: amount}("");
        emit CompletedPayment(sent);

        require(sent, "Failed to send Ether");
        _bank.updateLoan(this,_loan,amount);

    }
    



}