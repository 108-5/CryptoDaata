// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "./User.sol";

abstract contract Portfolio {
    struct Info{
        uint ID;
        uint256 amount;
        uint interestRate;
        uint period;
        uint tenure;
    }
    // Info info;

    uint256 finalAmount;

    // User _user;
    address bank;
    
    uint initTime;

    modifier onlyBank() {
        require(msg.sender==bank);
        _;
    }

    function getInitTime() public view returns(uint) {
        return initTime;
    }


    function getAmount() public view virtual returns (uint256);

    function getFinalAmount()public virtual returns(uint256);
}