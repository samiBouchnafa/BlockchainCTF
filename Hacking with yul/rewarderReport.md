## About the contrat rewarder

Purpose:

This contract manages a reward system where users can give rewards as tokens to other users by calling giveReward(address _user , IERC20 _token , uint _amount ) with ,specifying the user's address, token address, and reward amount

Users can withdraw their accumulated rewards by calling withdrawRewards() .

## Finding


### [H-1] A Denial of Service (DoS) attack in the Rewarder::giveReward function enables malicious actors to reward malicious tokens to users, thereby impeding their ability to retrieve all of their other rewards. 

**Description:** 

A malicious user can reward a normal user with a malicious token using the Rewarder::giveReward function. This token subsequently causes a revert in the Rewarder::withdrawReward function for the affected user, thereby preventing them from claiming their rewards.

When a user calls Rewarder::withdrawReward , for each reward/token he has , this code snippet runs :

``` javascript
try token.transfer(msg.sender , amount) {
                delete rewards[msg.sender][i];
            } catch (bytes memory reoson ) {
                string memory revertReoson = getRevertMessage(reoson);
                emit RewardTransferFailed(revertReoson);
            }
```
The hacker can manage to create a token where the transfer method results in a revert/error. They then manipulate the error message from token.transfer in such a way that it triggers an Out of Gas scenario. Specifically, they construct a series of bytes (reason) that, when passed to rewarder::getRevertMessage, exhausts the gas when attempting to decode the bytes into a string: getRevertMessage(reason). This action effectively halts the entire transaction, preventing any tokens from being withdrawn.

**Impact:**
A user will never be able to withdraw the tokens he owns ; the tokens will remain stuck in the contract indefinitely.
**Proof of Concept:**


**Recommended Mitigation:** 


a hacker with a malicious token that hinders them from withdrawing all their other rewards.
The code snippet responsible for returning the rewards includes a try-catch block designed to handle errors and prevent such issues.
However, our focus will be on exploiting the catch part of this error handling mechanism.
  in this snippet :
    try token.transfer(msg.sender , amount) {
                delete rewards[msg.sender][i];
            } catch (bytes memory reoson ) {
                string memory revertReoson = getRevertMessage(reoson);
                emit RewardTransferFailed(revertReoson);
            }
            
   If the transfer failed , the error (reoson) would be catched , and then would be somehow typecasted to a string using
   getRevertMessage() function . 
   the getRevertMessage() seems to abi.decode  the data (the error invoked by the token.transfer(msg.sender , amount)) 
   The thing is : the owner of the token is able to manipulate the revert/error message thrown by their transfer method.
   He can it make it malicious so that it causes a Dos attack (oog : out of gas) . How ? this is the interesting part 