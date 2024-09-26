// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract TheBlockchainMessenger {
    address public owner;
    uint public changeCounter;
    string public theMessage;

    constructor(){
        owner = msg.sender;
    }

    function updateMessage(string memory _newString) external {
        if(msg.sender == owner){
            theMessage = _newString;
            changeCounter++;
        }
    }

}