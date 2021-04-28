// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.6;
import './Token.sol';
import './Auction.sol';

contract AuctionFactory {
    address[] public auctions;
    address public tokenAddress;
    Token immutable token;

    constructor() public {
        tokenAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
        token = Token(tokenAddress);
    }
    
    function createAuction(uint bidIncrement, uint startTime, uint endTime, uint _tokenId) public {
        Auction newAuction = new Auction(msg.sender, bidIncrement, startTime, endTime, _tokenId);
        // 要先approve then transfer token to subcontract
        token.transferFrom(msg.sender, address(newAuction), _tokenId);
        auctions.push(address(newAuction));
    }

    function allAuctions() public view returns (address[] memory) {
        return auctions;
    }
}