const DMSFactory = artifacts.require("DMSFactory");

module.exports = (deployer) => {
    deployer.deploy(DMSFactory);
}
