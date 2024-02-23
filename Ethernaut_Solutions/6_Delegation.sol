// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Delegate {

  address public owner;

  constructor(address _owner) {
    owner = _owner;
  }

  function pwn() public {
    owner = msg.sender;
  }
}

contract Delegation {

  address public owner;
  Delegate delegate;

  constructor(address _delegateAddress) {
    delegate = Delegate(_delegateAddress);
    owner = msg.sender;
  }

  fallback() external {
    (bool result,) = address(delegate).delegatecall(msg.data);
    if (result) {
      this;
    }
  }
}
/*
When you get a new instance , a Delegation contract is deployed and not a Delegate contract 
if we successfully call the fallback() function ,  the contract will then delegate our call to the Delegate .
How can we call fallback() ? 
fallback() is called when you pass a function selector that doesn't exist in the contract .
Or if you send ether to a contract and receive() function dosn't exist 
Or if you send ether to a contract and msg.data is not empty 

In our case , we can trigger the f  fallback() function with the first option . let's say we pass a random function selector
the Delation contract will take that selector (that will be stored in msg.data ) . And will delegate this call to Delegate contract .
The same thing will happen , the Delegate contract will check if that function selector exist in the contract and if not it will assess that 
call using fallback() , except it doesn't have a fallback . So the fucntion selector has to match one of the functions . 

What will happen if  in the first place , we pass pwn() as a function selector (a function selector is bytes4 , each function has a selector ).
    1/ Delegation will not recognize pwn() . and this will trigger fallback() .
    2/ the contract will delegate this call to Delegate .
    3/ in the Delegate contract , pwn() will match the function and the execution will go .

How is the execution gonna go ? 
1/ Delegate call conserve the context of the call , msg.sender , msg.value will not change 
2/ msg.sender will be us , since we are the one who called in the first place 
3/ So pwn() will make us the owner 

Challege solved !


 */