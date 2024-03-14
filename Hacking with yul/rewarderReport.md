## About the contrat rewarder

Purpose:

This contract manages a reward system where users can give rewards as tokens to other users by calling giveReward(address _user , IERC20 _token , uint _amount ) with ,specifying the user's address, token address, and reward amount

Users can withdraw their accumulated rewards by calling withdrawRewards() .

## Finding


### [H-#] A Denial of Service (DoS) attack in the Rewarder::giveReward function enables malicious actors to reward malicious tokens to users, thereby impeding their ability to retrieve all of their other rewards. 

**Description:** 

**Impact:** 

**Proof of Concept:**

**Recommended Mitigation:** 


Our objective is to reward someone with a malicious token that hinders them from withdrawing all their other rewards.
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