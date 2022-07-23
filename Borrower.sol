// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "./User.sol";
import "./Loan.sol";

contract Borrower is User{
    UserInfo borrowerInfo;

    // Loan loan;
    
    constructor(UserInfo memory _borrowerInfo) {
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
        _bank.sanctionLoan(_loan,sent,data,this);
    }

    

    receive() external payable {}
    fallback() external payable {}


}