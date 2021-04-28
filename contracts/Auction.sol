// SPDX-License-Identifier: GPL-3.0
import './Token.sol';
pragma solidity ^0.6.6;

contract Auction {
    // static
    address public owner;
    uint public bidIncrement;
    uint public startTime;
    uint public endTime;
    uint public tokenId;

    // state
    uint public highestBindingBid;
    address public highestBidder;
    mapping(address => uint256) public fundsByBidder;
    bool ownerHasWithdrawn;
    Token immutable token;
    address tokenAddress;

    constructor(address _owner, uint _bidIncrement, uint _startTime, uint _endTime, uint _tokenId) public {
        // require(_startTime >= _endTime);
        // require(_startTime < now);
        // require(_owner == address(0));

        owner = _owner;
        bidIncrement = _bidIncrement;
        startTime = _startTime;
        endTime = _endTime;
        tokenId = _tokenId;
        tokenAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
        token = Token(tokenAddress);
        
    }

    function getHighestBid()
        view
        public
        returns (uint)
    {
        return fundsByBidder[highestBidder];
    }
    
    function min(uint a, uint b)
        private
        pure
        returns (uint)
    {
        if (a < b) return a;
        return b;
    }
    
    function placeBid()
        payable
        public
        returns (bool success)
    {
        require(msg.value != 0);

        uint newBid = fundsByBidder[msg.sender] + msg.value;

        require(newBid > highestBindingBid);

        uint highestBid = fundsByBidder[highestBidder];
        fundsByBidder[msg.sender] = newBid;

        if (newBid <= highestBid) {
            highestBindingBid = min(newBid + bidIncrement, highestBid);
        } else {
            if (msg.sender != highestBidder) {
                highestBidder = msg.sender;
                highestBindingBid = min(newBid, highestBid + bidIncrement);
            }
            highestBid = newBid;
        }
        return true;
    }
    
     function finalize()
        public
        returns (bool success)
    {
        address withdrawalAccount;
        uint withdrawalAmount;
        
        if (msg.sender == highestBidder) {
            token.approve(highestBidder, tokenId);
            token.transferFrom(address(this), highestBidder, tokenId);
            return true;

        } else {
            withdrawalAccount = msg.sender;
            withdrawalAmount = fundsByBidder[withdrawalAccount];
            
        }
        require(withdrawalAmount != 0) ;

        fundsByBidder[withdrawalAccount] -= withdrawalAmount;

        // transfer the funds
        msg.sender.transfer(withdrawalAmount);
        return true;
    }
}




   