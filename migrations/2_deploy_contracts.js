var Voting = artifacts.require("Voting");
var Token = artifacts.require("Token");


module.exports = (deployer, _votingBeginTime, _votingEndTime) => {
  const currentTime = parseInt(Date.now() / 1000); 
  deployer.deploy(Voting, currentTime+100, currentTime+10000);
  deployer.deploy(Token);
};