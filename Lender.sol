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
    
    Investment investment;

    receive() external payable {}
    fallback() external payable {}

    function invest(Bank _bank, Investment _investment) public{
        uint256 amount = _investment.getInvestmentAmount();
        require(address(this).balance>=amount,"Insufficient Balance");
        (bool sent, bytes memory data) = address(_bank).call{value: amount}("");
        require(sent,"Failed to send");
        // investment=_investment;
        // return msg.data;
    }
    
    // function withdraw()
}