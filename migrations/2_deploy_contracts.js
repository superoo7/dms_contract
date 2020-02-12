const DeadManSwitch = artifacts.require("DeadManSwitch");

module.exports = function (deployer, _network, accounts) {
  const willAccount = accounts[1];
  const blockDiff = 1;
  deployer.deploy(DeadManSwitch, blockDiff, willAccount);
};
