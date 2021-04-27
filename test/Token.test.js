const Token = artifacts.require("Token");

contract('Token', (accounts) => {
    let TokenInstance;

    before('Deploy Contracts', async() => {
        TokenInstance = await Token.new();
    });


    it('Create different Tokens which can be used to present a property in real world', async () => {
        await TokenInstance.mint("Sword+9", 10000000)
        await TokenInstance.mint("Axe+2", 1000000)
        const result1 = await TokenInstance._tokenURIs(0);
        const result2 = await TokenInstance._tokenURIs(1);
        assert.equal(result1, "Sword+9");
        assert.equal(result2, "Axe+2");
      });

    it('Every users can exchanged Tokens by their Ethers.', async () => {
        let rate = await TokenInstance._tokenRates(0);
        await TokenInstance.exchange(0, { 
            from: accounts[0],
            value: rate});
        let result = await TokenInstance.balanceOf(accounts[0]);
        assert.equal(result, 1, 'token balance Must be 1');
    });

    it('Every users can send his tokens to other users.', async () => {
        await TokenInstance.transfer(accounts[0], accounts[1], 0);
        let result = await TokenInstance.balanceOf(accounts[0]);
        assert.equal(result, 0, 'token balance must be 1');
        result = await TokenInstance.balanceOf(accounts[1]);
        assert.equal(result, 1, 'token balance must be 1');
    });

    it('Every users can query his balances of different tokens.', async () => {
        for (let i = 0; i < accounts.length; i++) {
            let balance  = await TokenInstance.balanceOf(accounts[i]);
            assert(balance);
        }
    });
});