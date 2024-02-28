// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MagicNum {

  address public solver;

  constructor() {}

  function setSolver(address _solver) public {
    solver = _solver;
  }
}
contract hack {
    MagicNum target ;
    constructor(address _address) {
        target = MagicNum(_address);
    }

    function attack() public {
        bytes memory code = hex"69602a60005260206000f3600052600a6016f3";
        address addr;
        assembly {
            addr := create(0 , add(code , 0x20) , 0x1a)
        }
        require(addr != address(0));
        target.setSolver(addr);
    }
    
}
