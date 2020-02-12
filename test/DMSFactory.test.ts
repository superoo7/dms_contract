const DMSFactory = artifacts.require(
    "DMSFactory"
);
const DMS = artifacts.require("DeadManSwitch")


contract("DMSFactory", (accounts) => {
    const owner = accounts[0];
    const beneficiary = accounts[1];
    const threshold = 10;

    it("create new DMS", async () => {
        const dmsFactory = await DMSFactory.deployed();
        const contract = await dmsFactory.create(threshold, beneficiary);
        assert(await dmsFactory.dmsAddress(0), contract.toString())
    })
})