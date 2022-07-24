// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "./User.sol";
import "./Bank.sol";
import "./Investment.sol";

contract Lender is User{
    UserInfo lenderInfo;
    
    constructor(UserInfo memory _lenderInfo) {
        lenderInfo = _lenderInfo;
        owner = payable(msg.sender);
    }
    
    event SuccessfullyInvested(address _from, address _to, bool _sent, bytes _data);
    event PaymentReceived(address _from, uint256 _amount);


    Investment investment;

    receive() external payable {
        emit PaymentReceived(msg.sender,msg.value);
    }
    fallback() external payable {}

    function invest(Bank _bank, Investment _investment) public{
        uint256 amount = _investment.getAmount();
        require(address(this).balance>=amount,"Insufficient Balance");
        (bool sent, bytes memory data) = address(_bank).call{value: amount}("");
        require(sent,"Failed to send");
        emit SuccessfullyInvested(address(this), address(_bank),sent,data);
    }

    function withdraw(Bank _bank, Investment _investment) public {
        _bank.redeemInvestment(this,_investment);
    }
    
}