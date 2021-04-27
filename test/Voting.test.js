const timeMachine = require('ganache-time-traveler');
const Voting = artifacts.require("Voting");



contract('Voting', (accounts) => {
    let VotingInstance;
    let currentTime;
    let bTime;
    let eTime;
    beforeEach(async() => {
        let snapshot = await timeMachine.takeSnapshot();
        snapshotId = snapshot['result'];
    });

    afterEach(async() => {
        await timeMachine.revertToSnapshot(snapshotId);
    });

    before('Deploy Contracts', async() => {
        currentTime = parseInt(Date.now() / 1000)
        bTime = currentTime + 100;
        eTime = currentTime + 10000;
        VotingInstance = await Voting.new(bTime, eTime);
    });


    it('A voting will begin and end at the appointed time.', async () => {
      const beginTime = await VotingInstance.votingBeginTime.call();
      const endTime = await VotingInstance.votingEndTime.call();
      assert.equal(bTime, beginTime,'Begintime not equal.');
      assert.equal(eTime, endTime,'Endtime not equal.');
      });

    it('Before a voting, everyone can propose their proposals.', async () => {
        await VotingInstance.createProposal("shao", "shaoContent");
        const results = await VotingInstance.proposals.call(0);
        assert.equal(results.proposer, accounts[0],'proposer is not equal to account');
    });

    it('During a voting, everyone can vote & choose their favorite proposals.', async () => {
        await VotingInstance.createProposal("shao1", "shaoContent1");
        // advance time to voting period
        await timeMachine.advanceTimeAndBlock(1000);
        await VotingInstance.vote(0);
        const result = await VotingInstance.proposals.call(0);
        const votingCount0 = result.voteCount;
        assert.equal(votingCount0, 1, 'voteCount must be 1');
    });

    it('After the voting ends, the proposal with the highest votes will become the winner proposal and will be announced.', async () => {
        await VotingInstance.createProposal("shao1", "shaoContent1");
        // advance time to voting period
        await timeMachine.advanceTimeAndBlock(1000);
        await VotingInstance.vote(0)
        // advance time to voting end
        await timeMachine.advanceTimeAndBlock(100000);
        const winningResult = await VotingInstance.winningProposal();
        assert.equal(winningResult, 0, 'Winning Index must be 0');    
        
    });
});

