var Voting = artifacts.require("Voting");
var Token = artifacts.require("Token");


module.exports = (deployer, _votingBeginTime, _votingEndTime) => {
  deployer.deploy(Voting, 1619493896, 1619499999);
  deployer.deploy(Token);
};