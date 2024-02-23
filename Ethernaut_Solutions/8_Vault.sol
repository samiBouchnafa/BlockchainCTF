// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vault {
  bool public locked;
  bytes32 private password;

  constructor(bytes32 _password) {
    locked = true;
    password = _password;
  }

  function unlock(bytes32 _password) public {
    if (password == _password) {
      locked = false;
    }
  }

  /* 
  In the console , we can read all the storage slots using web3.eth.getStorageAt(address , slotnumber )
  In this example , the dev thought that , by making the password private , no one could read it .
  But in the blockchain , everything onchain is visible .
  We just need to locate which slot that variable is stored and we can read it . 
  the first state variable (bool public locked ) , is held in first slot (slot 0) , occupying only one byte .
  the second state variable (bytes32 private password ) , is stored in the second slot (slot 1) , since it is 32 bytes long (maximum capacity).
  so the command that we have to run is . web3.eth.getStorageAt(instance , 1);
  We get the password , and we unlock the vault from the console usong the command : contract.unlock(password).
  
   */