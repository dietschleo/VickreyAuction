// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VickreyAuction {
    address public owner;
    uint256 public constant MAX_USERS = 2; // Maximum number of bidders
    bool public auctionEnded = false;
    
    struct Bid {
        address bidder;
        uint256 amount;
    }

    Bid[] public bids; // Store all bids
    mapping(address => uint256) public userBids; // Track user bids
    address public winner;
    uint256 public winningBid;
    uint256 public secondHighestBid;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this");
        _;
    }

    modifier auctionActive() {
        require(!auctionEnded, "Auction has already ended");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to place a bid
    function placeBid() external payable auctionActive {
        require(msg.value > 0, "Bid amount must be greater than 0");
        require(userBids[msg.sender] == 0, "You can only bid once");
        require(bids.length < MAX_USERS, "Maximum bidders reached");

        bids.push(Bid(msg.sender, msg.value));
        userBids[msg.sender] = msg.value;
    }

    // Owner determines the winner after MAX_USERS bids
    function determineWinner() external onlyOwner auctionActive {
        require(bids.length == MAX_USERS, "Not enough bidders yet");

        auctionEnded = true;

        // Sort bids in descending order
        for (uint256 i = 0; i < bids.length; i++) {
            for (uint256 j = i + 1; j < bids.length; j++) {
                if (bids[j].amount > bids[i].amount) {
                    Bid memory temp = bids[i]; // Swap bids using temp variables
                    bids[i] = bids[j];
                    bids[j] = temp;
                }
            }
        }

        // Assign winner and second highest bid
        winner = bids[0].bidder;
        winningBid = bids[0].amount;
        secondHighestBid = bids[1].amount;
    }

    // Refund losing bidders
    function refundLosers() external {
        require(auctionEnded, "Auction is still active");

        for (uint256 i = 1; i < bids.length; i++) {
            address payable loser = payable(bids[i].bidder);
            uint256 refundAmount = bids[i].amount;
            bids[i].amount = 0; // Prevent re-entrancy
            loser.transfer(refundAmount);
        }
    }

    // Winner pays only the second-highest bid
    function finalizeAuction() external {
        require(auctionEnded, "Auction is still active");
        require(msg.sender == winner, "Only the winner can finalize");
        require(address(this).balance >= (winningBid - secondHighestBid), "Not enough balance");

        payable(winner).transfer(winningBid - secondHighestBid);
    }

    // Owner can withdraw the winning bid amount
    function ownerWithdraw() external onlyOwner {
        require(auctionEnded, "Auction is still active");
        require(address(this).balance >= secondHighestBid, "Insufficient balance");

        payable(owner).transfer(secondHighestBid);
    }

    // Reset auction for a new round
    function resetAuction() external onlyOwner {
    require(auctionEnded, "Cannot reset while auction is active");

    // Clear mapping before deleting the array
    for (uint256 i = 0; i < bids.length; i++) {
        delete userBids[bids[i].bidder];
    }

    delete bids; // Now it's safe to delete the array

    winner = address(0);
    winningBid = 0;
    secondHighestBid = 0;
    auctionEnded = false;
}


    // Function to view current bids (for debugging)
    function getBids() external view returns (Bid[] memory) {
        return bids;
    }

    // Receive function to accept Ether
    receive() external payable {}
}
