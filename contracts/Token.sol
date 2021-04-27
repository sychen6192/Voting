// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.6;

contract Token {
    
    mapping (address => uint256) private _balances;
    mapping (uint256 => address) private _owners;
    mapping (uint256 => string) public _tokenURIs;
    mapping (uint256 => uint256) public _tokenRates;
    address public manager;
    uint private _tokenIds;
    
    constructor() public {
        _tokenIds = 0;
        manager = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == manager, "Permission denied.");
        _;
    }
    
    // Create different Tokens which can be used to present a property in real world
    function mint(string memory _tokenURI, uint256 _tokenRate) public onlyOwner{
        // mint to contract address
        _mint(address(this), _tokenIds);
        // define different metadata, different exchange rate (optional)
        _setTokenURI(_tokenIds, _tokenURI, _tokenRate);
        _tokenIds++;
    }
    
    function _mint(address to, uint256 tokenId) internal{
        require(to != address(0), "mint to the zero address");
        require(!_exists(tokenId), "token already minted");
        
        _balances[to] += 1;
        _owners[tokenId] = to;

    }
    
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }
    
    function _setTokenURI(uint256 tokenId, string memory _tokenURI, uint256 _tokenRate) internal virtual {
        require(_exists(tokenId), "URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
        _tokenRates[tokenId] = _tokenRate;
    }
    
    // Every users can send his tokens to other users
    function transfer(address from, address to, uint256 tokenId) public {
        require(msg.sender == from, 'You are not owner');
        require(_owners[tokenId] == from, "transfer of token that is not own");
        require(to != address(0), "transfer to the zero address");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

    }
    
    // Every users can query his balances of different tokens
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0),  "alance query for the zero address");
        return _balances[owner];
    }
    
    // Every users can exchanged Tokens by their Ethers
    function exchange(uint256 _tokenId) public payable {
        require(msg.sender != address(0),  "balance query for the zero address");
        require(_owners[_tokenId] == address(this), "token has been sold");
        require(msg.value >= _tokenRates[_tokenId], "insufficient ethers");
        
        _balances[address(this)] -= 1;
        _balances[msg.sender] += 1;
        _owners[_tokenId] = msg.sender;
    }
}