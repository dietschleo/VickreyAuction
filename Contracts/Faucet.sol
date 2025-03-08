// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Faucet {
    address public owner;
    uint256 public constant MAX_AMOUNT = 0.1 ether; // Set max withdrawal amount

    constructor() {
        owner = msg.sender;
    }

    // Function to deposit funds into the contract
    function deposit() external payable {}

    // Function to withdraw funds with a limit
    function withdraw(uint256 _amount) external {
        require(_amount <= MAX_AMOUNT, "Withdrawal exceeds max amount");
        require(address(this).balance >= _amount, "Not enough balance in faucet");

        payable(msg.sender).transfer(_amount);
    }

    // Fallback function to receive ETH
    receive() external payable {}
}
