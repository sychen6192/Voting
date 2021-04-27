// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.6;

contract Voting {
    
    Proposal[] public proposals;
    uint public votingBeginTime;
    uint public votingEndTime;
    mapping(address => Voter) public voters;
    address public chairperson;
    uint private _ballotCounter;

        
    mapping(address => uint) public ballotNumber;


    struct Proposal {
        string name;
        string content;
        uint voteCount;
        address proposer;
    }
    
    struct Voter {
        uint weight;
        bool voted;
        uint vote;
    }
    
    modifier onlyChairPerson() {
        require(msg.sender == chairperson, "Permission denied.");
        _;
    }
    
    modifier checkVotingPeriod() {
        require(now > votingBeginTime && now < votingEndTime, 'Voting ended');
        _;
    }
    
    modifier checkVotingStart() {
        require(now < votingBeginTime, 'Voting has started');
        _;
    }
    
    modifier checkVotingEnd() {
        require(now > votingEndTime, 'have not ended');
        _;
    }
    
    // A voting will begin and end at the appointed time.
    constructor(
        uint _votingBeginTime,
        uint _votingEndTime
        ) public {
        votingBeginTime = _votingBeginTime;
        votingEndTime = _votingEndTime;
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        _ballotCounter = 0;
    }
    
    function extendVoting(uint timeBySec) public onlyChairPerson checkVotingPeriod {
        votingEndTime = votingEndTime + timeBySec;
    }
    
    function giveRightToVote(address voter, uint weight) public onlyChairPerson {
        require(!voters[voter].voted);
        require(voters[voter].weight == 0);
        
        voters[voter].weight = weight;
    }
    
    // Before a voting, everyone can propose their proposals.
    function createProposal(string memory pName, string memory pContent) public checkVotingStart {
        Proposal memory newProposal = Proposal({
            name: pName,
            content: pContent,
            voteCount: 0,
            proposer: msg.sender
        });
        
        proposals.push(newProposal);
    }
    
    // During a voting, everyone can vote & choose their favorite proposals
    function vote(uint proposal) public checkVotingPeriod {
        require(voters[msg.sender].voted == false, 'you have voted.');
        proposals[proposal].voteCount = voters[msg.sender].weight;
        voters[msg.sender].voted = true;
        voters[msg.sender].vote = proposal;
        ballotNumber[msg.sender] = _ballotCounter++;
    }
    
    /* After the voting ends, the proposal with the highest votes will become 
    the winner proposal and will be announced.
    */
    function winningProposal() public checkVotingEnd view returns(uint)  {
        require(proposals.length > 0, 'no proposals');
        uint winningVoteCount = 0;
        uint winnerIndex = 0;
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winnerIndex = i;
            }
        }
        return winnerIndex;
    }
    
    
    
}