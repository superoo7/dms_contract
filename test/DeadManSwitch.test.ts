import BigNumber from "bignumber.js";

const DeadManSwitch = artifacts.require(
  "DeadManSwitch"
);
const Erc20Token = artifacts.require("HuntToken");

const oneEther = web3.utils.toWei("1", "ether");

contract("DeadManSwitch", accounts => {
  const owner = accounts[0];
  const beneficiary = accounts[1];

  it("should allow owner to proveAlive and update lastCheckInBlock to latest block", async () => {
    const deadManSwitch = await DeadManSwitch.deployed();
    const currentBlock = await web3.eth.getBlockNumber();
    await deadManSwitch.proveAlive();
    assert.equal(
      (await deadManSwitch.lastCheckInBlock()).toString(),
      new BigNumber(currentBlock + 1).toString()
    );
  });

  it("should allow beneficiary account to claim the ether", async () => {
    const deadManSwitch = await DeadManSwitch.deployed();
    await deadManSwitch.proveAlive({ from: owner });
    const isDead1 = await deadManSwitch.isDead();
    assert.equal(isDead1, false);
    const intialBalance = new BigNumber(await web3.eth.getBalance(accounts[1]));
    await web3.eth.sendTransaction({
      from: owner,
      to: deadManSwitch.address,
      value: oneEther
    });
    const isDead2 = await deadManSwitch.isDead();
    assert.equal(isDead2, true);
    await deadManSwitch.withdrawEther(oneEther, {
      from: beneficiary,
    });
    const finalBalance = new BigNumber(await web3.eth.getBalance(accounts[1]));
    assert.equal(
      finalBalance.toPrecision(4).toString(),
      intialBalance
        .plus(web3.utils.toWei("1", "ether"))
        .toPrecision(4).toString()
    );
  });

  it("allows owner to refund the ether in the contract", async () => {
    const deadManSwitch = await DeadManSwitch.deployed();
    await web3.eth.sendTransaction({
      from: owner,
      to: deadManSwitch.address,
      value: oneEther
    });
    const initialBalance = new BigNumber(await web3.eth.getBalance(owner))
    await deadManSwitch.withdrawEther(oneEther)
    const finalBalance = new BigNumber(await web3.eth.getBalance(owner))
    assert.equal(
      finalBalance.toPrecision(4).toString(),
      initialBalance
        .plus(oneEther)
        .toPrecision(4).toString()
    )
  })

  it("allows update of block threshold", async () => {
    const deadManSwitch = await DeadManSwitch.deployed()
    await deadManSwitch.updateBlockThreshold(100);
    assert.equal((await deadManSwitch.blockThreshold()).toString(), "100")
  })

  it("allows transfer of erc 20 token into the contract", async () => {
    const deadManSwitch = await DeadManSwitch.deployed()
    const erc20 = await Erc20Token.deployed();
    const totalSupply = await erc20.totalSupply();
    assert.equal(((await erc20.balanceOf(owner)).toString()), totalSupply.toString());
    await erc20.approve(deadManSwitch.address, totalSupply)
    await deadManSwitch.depositERC20(erc20.address, totalSupply);
    assert.equal((await erc20.balanceOf(deadManSwitch.address)).toString(), totalSupply.toString())
    await deadManSwitch.withdrawERC20(erc20.address, totalSupply);
    assert.equal((await erc20.balanceOf(owner)).toString(), totalSupply.toString())
  })

});
