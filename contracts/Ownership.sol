pragma solidity >=0.6.0 <0.7.0;

import "./lib/Ownable.sol";

/**
 * @title Reference implementation of the Ownership, where it contains a single owner and a single beneficiary, and allow transfer of ownership
 */
contract Ownership is Ownable {
    /**
     * @dev the beneficiaryAccount where the DeadManSwitch's contract will send when the contract expires.
     */
    address private _beneficiary;

    event BeneficiaryTransferred(
        address indexed previousBeneficiary,
        address indexed newBeneficiary
    );

    constructor(address beneficiaryAddress) internal {
        _beneficiary = beneficiaryAddress;
        emit BeneficiaryTransferred(address(0), beneficiaryAddress);
    }

    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    modifier onlyBeneficiary() {
        require(isBeneficiary(), "Beneficiary: caller is not the beneficiary");
        _;
    }

    function isBeneficiary() public view returns (bool) {
        return _msgSender() == _beneficiary;
    }

    function transferBeneficiary(address newBeneficiary) public onlyOwner {
        _transferBeneficiary(newBeneficiary);
    }

    function _transferBeneficiary(address newBeneficiary) internal {
        require(
            newBeneficiary != address(0),
            "Beneficiary: new owner is the zero address"
        );
        emit BeneficiaryTransferred(_beneficiary, newBeneficiary);
        _beneficiary = newBeneficiary;
    }
}
