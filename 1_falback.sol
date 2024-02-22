/* 
In this level , you have to become the owner and then drain the contract's balance .
There are two functions that set the owner to the address of msg.sender .
The first one is "contribute" : If your contributions are higher than the owner's 
you become the owner . But this is impossible because in the constructor . The deployer 
set the contribution to 1000 ether for the owner ! So you have to contribute with more than 1000 ether
to become the owner (lol).
the second one is : receive() . If you send ether through receive and contributions[msg.sender] > 0 
Then you become the owner .
The plan is now simple : 
1/ Contribute by a small amount 
2/ call the contract with a function selector that doesn't exist (in order to trigger the receive function ). and send some ether
3/ call the function withdraw 
*/

