// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AugmentedFaucet {
    address public owner;
    uint256 public constant MAX_AMOUNT = 0.1 ether; // Max withdrawal per request
    uint256 public constant MAX_USERS = 4; // Max unique users allowed to withdraw

    mapping(address => bool) public hasWithdrawnBefore;
    address[] public uniqueUsers; // Stores users who have withdrawn

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to deposit funds into the contract
    function deposit() external payable {}

    // Function to withdraw funds with restrictions
    function withdraw(uint256 _amount) external {
        require(_amount <= MAX_AMOUNT, "Withdrawal exceeds max amount");
        require(address(this).balance >= _amount, "Not enough balance in faucet");

        // If the user has never withdrawn before, check against MAX_USERS limit
        if (!hasWithdrawnBefore[msg.sender]) {
            require(uniqueUsers.length < MAX_USERS, "Max users reached, no new users can withdraw");
            uniqueUsers.push(msg.sender); // Add new user to list
            hasWithdrawnBefore[msg.sender] = true;
        }

        payable(msg.sender).transfer(_amount);
    }

    // Function for the owner to reset the user list (allows new users to withdraw)
    function resetUsers() external onlyOwner {
        for (uint256 i = 0; i < uniqueUsers.length; i++) {
            hasWithdrawnBefore[uniqueUsers[i]] = false;
        }
        delete uniqueUsers; // Clears the user list
    }

    // Function to get the number of unique users who have withdrawn
    function getUniqueUserCount() external view returns (uint256) {
        return uniqueUsers.length;
    }

    // Fallback function to receive ETH
    receive() external payable {}
}
