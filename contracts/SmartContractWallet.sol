// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract SmartContractWallet {
    address payable owner;
    mapping (address => uint) public allowance;
    mapping (address => bool) public isAllowToSend;
    mapping (address => bool) public guardian;
    address payable nextOwner; 
    uint guardiansResetCount;
    uint public constant confirmationsFromGuardiansForReset = 3;

    constructor(){
        owner = payable (msg.sender);
    }

    function proposeNewOwner(address payable newOwner) public {
        require(guardian[msg.sender], "You are no guardian, aborting");
        if(nextOwner != newOwner){
            nextOwner = newOwner;
            guardiansResetCount = 0;
        }

        guardiansResetCount++;

        if(guardiansResetCount >= confirmationsFromGuardiansForReset){
            owner = newOwner;
            nextOwner = payable (address(0));
        }
    }

    function denySending(address _from) public {
        require(msg.sender == owner, "You are not the owner, aborting");
        isAllowToSend[_from] = false;
    }

    function setAllowance(address _from, uint _amount) public {
        require(msg.sender == owner, "your are not the owner, aborting");
        allowance[_from] = _amount;
        isAllowToSend[_from] = true;
    }

    function transfer(address payable _to, uint _amount, bytes memory _payload) public returns(bytes memory){
        require(_amount <= address(this).balance);
        if(msg.sender != owner){
            require(isAllowToSend[msg.sender], "You are not allowed to send any transactions, aborting");
            require(allowance[msg.sender] >= _amount, "You are trying to send more than you are allowed to, aborting");
            allowance[msg.sender] -= _amount;
        }
        (bool success, bytes memory returnData) = _to.call{value:_amount}(_payload);
        require(success, "Aborting, call was not successful");
        return returnData;
    }

    receive() external  payable {}
}