const ERC20Token = artifacts.require("HuntToken");

module.exports = function (deployer) {
    deployer.deploy(ERC20Token);
};
