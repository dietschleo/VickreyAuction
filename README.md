# About

This repository contains Solidity smart contracts deployed on the **Sepolia testnet**, including a **Faucet**, an **Augmented Faucet** with user limits, and a **Vickrey Auction** for sealed-bid auctions. These contracts are designed for **testing, experimentation, and learning**.

Each contract includes:
- A detailed **code breakdown**.
- Deployment **instructions** for **Remix IDE**.
- Links to **Etherscan** for verification and interaction.

Whether you're exploring **smart contract development**, testing on a **live testnet**, or improving **Solidity skills**, this repository provides a practical foundation.


# Table of Contents

- [About](#about)
- [Table of Contents](#table-of-contents)
- [How To Run](#how-to-run)
- [Addresses](#addresses)
  - [Faucet](#faucet)
  - [Augmented Faucet](#augmented-faucet)
  - [Vickrey Auction for 2 users](#vickrey-auction-for-2-users)
- [Code Structure](#code-structure)
  - [Faucet Contract - Structure and Core Functions](#faucet-contract---structure-and-core-functions)
    - [1. Contract Overview](#1-contract-overview)
      - [Key Components](#key-components)
    - [2. Contract Initialization](#2-contract-initialization)
    - [3. Depositing Funds](#3-depositing-funds)
      - [Function: `deposit()`](#function-deposit)
    - [4. Withdrawals](#4-withdrawals)
      - [Function: `withdraw()`](#function-withdraw)
    - [5. Ether Handling](#5-ether-handling)
  - [Augmented Faucet Contract - Additional Features and Enhancements](#augmented-faucet-contract---additional-features-and-enhancements)
    - [1. Enhancements Over Basic Faucet](#1-enhancements-over-basic-faucet)
    - [2. User Tracking and Withdrawal Restrictions](#2-user-tracking-and-withdrawal-restrictions)
      - [Function: `withdraw()` (Enhanced)](#function-withdraw-enhanced)
    - [3. Owner-Controlled User Reset](#3-owner-controlled-user-reset)
      - [Function: `resetUsers()`](#function-resetusers)
    - [4. Additional Utility Function](#4-additional-utility-function)
      - [Function: `getUniqueUserCount()`](#function-getuniqueusercount)
  - [Vickrey Auction Contract Structure and Core Functions](#vickrey-auction-contract-structure-and-core-functions)
    - [1. Contract Overview](#1-contract-overview-1)
      - [Key Components](#key-components-1)
    - [2. Contract Initialization](#2-contract-initialization-1)
      - [Modifier: onlyOwner](#modifier-onlyowner)
    - [3. Bidding Mechanism](#3-bidding-mechanism)
      - [Function: `placeBid()`](#function-placebid)
    - [4. Determining the Winner](#4-determining-the-winner)
      - [Function: `determineWinner()`](#function-determinewinner)
    - [5. Refunds and Payments](#5-refunds-and-payments)
      - [Refund Losing Bidders](#refund-losing-bidders)
      - [Winner Pays Second-Highest Bid](#winner-pays-second-highest-bid)
      - [Owner Withdraws Funds](#owner-withdraws-funds)
    - [6. Resetting the Auction](#6-resetting-the-auction)


# How To Run
1. Open the [Remix IDE](https://remix.ethereum.org/)
2. Upload the .sol file of the contract of your choice

The .json file associated should also included as it contains the ABI necessary to run the existing program.

3. Compile and run the .sol file 

This can be achieved from the *Solidity Compiler* Tab.

4. Run from the public address of the chosen contract

Use the *Deploy & Run Transaction* Tab. The addresses can be retrieved below. 

# Addresses

## Faucet
Deployed on the Sepolia testnet and available at: 
>0xa3BcE68C5e8ddDF02525b1bD06c667C45303b3Bf

[View on Etherscan](https://sepolia.etherscan.io/address/0xa3BcE68C5e8ddDF02525b1bD06c667C45303b3Bf)


## Augmented Faucet
Deployed on the Sepolia testnet and available at:
>0x6A7384e2DBf1386C459EC8FE54f81a84f72fF716

[View on Etherscan](https://sepolia.etherscan.io/address/0x6A7384e2DBf1386C459EC8FE54f81a84f72fF716)


## Vickrey Auction for 2 users
Deployed on the Sepolia testnet and available at:
>0x9fE99A543cB83e8B58ac78EEC56C8aF46F5bD30E

[View on Etherscan](https://sepolia.etherscan.io/address/0x9fE99A543cB83e8B58ac78EEC56C8aF46F5bD30E)


# Code Structure

## Faucet Contract - Structure and Core Functions

### 1. Contract Overview
A simple Faucet contract that allows users to deposit and withdraw ETH with a fixed withdrawal limit. The contract is owned by the deployer but does not enforce ownership controls beyond deployment.

#### Key Components
- State Variables: Owner and maximum withdrawal limit.
- Core Functions:
  - `deposit()`
  - `withdraw()`
  - `receive()`

---

### 2. Contract Initialization
```
address public owner;
uint256 public constant MAX_AMOUNT = 0.1 ether;

constructor() {
    owner = msg.sender;
}
```
- Owner is assigned at deployment but has no special privileges.
- `MAX_AMOUNT` is set to `0.1 ETH` per withdrawal.

---

### 3. Depositing Funds
#### Function: `deposit()`
```
function deposit() external payable {}
```
- Allows anyone to send ETH to the contract.
- Does not enforce sender verification.
- Funds accumulate in the contract balance.

---

### 4. Withdrawals
#### Function: `withdraw()`
```
function withdraw(uint256 _amount) external {
    require(_amount <= MAX_AMOUNT, "Withdrawal exceeds max amount");
    require(address(this).balance >= _amount, "Not enough balance in faucet");

    payable(msg.sender).transfer(_amount);
}
```
- Allows any user to withdraw up to 0.1 ETH per request.
- Ensures the contract has enough balance before transferring ETH.

### 5. Ether Handling
```
receive() external payable {}
```
- Allows the contract to receive ETH directly without calling `deposit()`.

---

## Augmented Faucet Contract - Additional Features and Enhancements

### 1. Enhancements Over Basic Faucet
This Augmented Faucet builds on the basic faucet contract by adding restrictions on who can withdraw. The main improvements include:
- Limits unique users: Only `MAX_USERS = 4` unique addresses can withdraw.
- Tracks user withdrawals: Uses a mapping to check if a user has withdrawn before.
- Adds a reset mechanism: The owner can reset the user list to allow new users.

---

### 2. User Tracking and Withdrawal Restrictions
#### Function: `withdraw()` (Enhanced)
```
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
```
- Prevents unlimited withdrawals:  
  - Users who have already withdrawn can still withdraw.  
  - New users are limited to `MAX_USERS` (4 unique users max).  
- Tracks first-time withdrawers using `hasWithdrawnBefore` mapping.

---

### 3. Owner-Controlled User Reset
#### Function: `resetUsers()`
```
function resetUsers() external onlyOwner {
    for (uint256 i = 0; i < uniqueUsers.length; i++) {
        hasWithdrawnBefore[uniqueUsers[i]] = false;
    }
    delete uniqueUsers; // Clears the user list
}
```
- Allows the owner to reset the faucet.
- Clears the withdrawal tracking, allowing new users to withdraw.
- Does not reset contract balance, only user tracking.

---

### 4. Additional Utility Function
#### Function: `getUniqueUserCount()`
```
function getUniqueUserCount() external view returns (uint256) {
    return uniqueUsers.length;
}
```
- Returns the number of unique users who have withdrawn.
- Useful for tracking faucet activity.

---

## Vickrey Auction Contract Structure and Core Functions

### 1. Contract Overview
Implements a Vickrey auction where the highest bidder wins but pays only the second-highest bid. The auction is manually finalized by the owner.

#### Key Components
State Variables: Track bids, winner, and auction status.
Modifiers: Restrict access (`onlyOwner`, `auctionActive`).
Core Functions:
  - `placeBid()`
  - `determineWinner()`
  - `refundLosers()`
  - `finalizeAuction()`
  - `ownerWithdraw()`
  - `resetAuction()`

---

### 2. Contract Initialization
```
address public owner;

constructor() {
    owner = msg.sender;
}
```
Owner is set at deployment and controls key functions.

#### Modifier: onlyOwner
```
modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner can call this");
    _;
}
```
Restricts function access to the contract owner.

---

### 3. Bidding Mechanism
#### Function: `placeBid()`
```
function placeBid() external payable auctionActive {
    require(msg.value > 0, "Bid amount must be greater than 0");
    require(userBids[msg.sender] == 0, "You can only bid once");
    require(bids.length < MAX_USERS, "Maximum bidders reached");

    bids.push(Bid(msg.sender, msg.value));
    userBids[msg.sender] = msg.value;
}
```
Allows one bid per user, stops at `MAX_USERS`, and requires ETH.

---

### 4. Determining the Winner
#### Function: `determineWinner()`
```
function determineWinner() external onlyOwner auctionActive {
    require(bids.length == MAX_USERS, "Not enough bidders yet");
    auctionEnded = true;

    for (uint256 i = 0; i < bids.length; i++) {
        for (uint256 j = i + 1; j < bids.length; j++) {
            if (bids[j].amount > bids[i].amount) {
                Bid memory temp = bids[i];
                bids[i] = bids[j];
                bids[j] = temp;
            }
        }
    }

    winner = bids[0].bidder;
    winningBid = bids[0].amount;
    secondHighestBid = bids[1].amount;
}
```
- Manually triggered by the owner.
- Sorts bids (bubble sort, inefficient).
- Selects the winner and determines the price they pay.

---

### 5. Refunds and Payments
#### Refund Losing Bidders
```
function refundLosers() external {
    require(auctionEnded, "Auction is still active");

    for (uint256 i = 1; i < bids.length; i++) {
        address payable loser = payable(bids[i].bidder);
        loser.transfer(bids[i].amount);
        bids[i].amount = 0; // Prevent re-entrancy
    }
}
```
Refunds all non-winning bidders.

#### Winner Pays Second-Highest Bid
```
function finalizeAuction() external {
    require(auctionEnded, "Auction is still active");
    require(msg.sender == winner, "Only the winner can finalize");

    payable(winner).transfer(winningBid secondHighestBid);
}
```
The winner only pays the second-highest bid.

#### Owner Withdraws Funds
```
function ownerWithdraw() external onlyOwner {
    require(auctionEnded, "Auction is still active");

    payable(owner).transfer(secondHighestBid);
}
```
The owner collects the second-highest bid amount.

---

### 6. Resetting the Auction
```
function resetAuction() external onlyOwner {
    require(auctionEnded, "Cannot reset while auction is active");

    for (uint256 i = 0; i < bids.length; i++) {
        delete userBids[bids[i].bidder];
    }

    delete bids;

    winner = address(0);
    winningBid = 0;
    secondHighestBid = 0;
    auctionEnded = false;
}
```
Clears all bid data and resets the auction.

