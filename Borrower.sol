// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "./User.sol";
import "./Loan.sol";

contract Borrower is User{
    UserInfo borrowerInfo;

    event Pay(address _from, address _to, bool _sent, bytes _data);

    
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
        emit Pay(address(this),address(_bank),sent,data);
        _bank.sanctionLoan(_loan,sent,data,this);
    }

    function payLoan(Bank _bank, Loan _loan,uint256 amount) public {
        uint finalAmount = _loan.getFinalAmount();
        require(address(this).balance > finalAmount,"Insufficient Funds");
        if (amount>finalAmount){
            amount = finalAmount;
        }
        (bool sent, bytes memory data) = address(_bank).call{value: amount}("");
        emit Pay(address(this),address(_bank),sent,data);

        require(sent, "Failed to send Ether");
        // _bank.verifyPayment(_loan,sent,data,this);
        _bank.updateLoan(this,_loan,sent,data,amount);

    }
    

    receive() external payable {}
    fallback() external payable {}


}