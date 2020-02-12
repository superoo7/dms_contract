# DMS Contract

DMS Contract is an implementation of [Dead Man's Switch](https://en.wikipedia.org/wiki/Dead_man%27s_switch) in Ethereum blockchain written in Solidity.

This contract are still Work in Progress, and haven't been audited, use with care.

# Explanation

From Wikipedia:

> Software versions of dead man's switches are generally only used by people with technical expertise, and can serve several purposes, such as sending a notification to friends or deleting and encrypting data. The "non-event" triggering these can be almost anything, such as failing to log in for 7 consecutive days, not responding to an automated e-mail, ping, a GPS-enabled telephone not moving for a period of time, or merely failing to type a code within a few minutes of a computer's boot.

## Feature

- A Contract Factory that allows anyone to create new contract. (Refer to [DMSFactory](./contracts/DMSFactory.sol))
- Allow the genareted contract to set a single beneficiary and the creator of the contract will be the owner.
- Owner are allowed to change owner and beneficiary. (Refer to [Ownership](./contracts/Ownership.sol))
- Allow deposit of ERC20 token and Ether into the contract address. (acts like a wallet)
- Beneficiary are only allowed to access to the wallet only if the owner aren't able to update the lastCheckInBlock.
- Owner can withdraw ether and erc20 any time.
- Owner can set a threshold of block number.

## Technology used

- Solidity
- Truffle
- Typescript
- Mocha & Chai
- Typechain
