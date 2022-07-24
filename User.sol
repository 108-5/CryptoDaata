// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

abstract contract User {
    struct UserInfo{
        uint ID;
        string name;
    }
    address payable public owner;

    modifier onlyOwner(){
        require(msg.sender==owner, "Caller is not the owner");
        _;
    }

    function getBalance() onlyOwner public view returns(uint256){
        return address(this).balance;
    }

}