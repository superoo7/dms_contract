pragma solidity >=0.6.0 <0.7.0;

import "./DeadManSwitch.sol";

/**
 * @title Reference implementation of the DeadManSwitch Factory in order to keep track of all DMS addresses
 */
contract DMSFactory {
    string public constant version = "1.0.0";
    address public owner;
    address[] public dmsAddress;

    constructor() public {
        owner = msg.sender;
    }

    function count() public view returns (uint256) {
        return dmsAddress.length;
    }

    function create(
        uint256 _blockThreshold,
        address payable _beneficiaryAccount
    ) public returns (address) {
        DeadManSwitch dms = new DeadManSwitch(
            _blockThreshold,
            _beneficiaryAccount
        );
        address contractAddress = address(dms);
        dmsAddress.push(contractAddress);
        return contractAddress;
    }
}
