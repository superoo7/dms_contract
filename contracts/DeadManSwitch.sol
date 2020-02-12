pragma solidity >=0.6.0 <0.7.0;

import "./Ownership.sol";
import "./lib/SafeMath.sol";
import "./lib/IERC20.sol";

/**
 * @title Reference implementation of the DeadManSwitch for Ether and ERC20 token locked.
 */
contract DeadManSwitch is Ownership {
    using SafeMath for uint256;

    // Storage
    /**
     * @dev Returns the last time the owner call `proveAlive` on which block.
     */
    uint256 public lastCheckInBlock;
    /**
     * @dev Returns the threshold block difference in order to allow `claim()` to be called
     * Useful for setting a certain period of time to `prove`.
     */
    uint256 public blockThreshold;


    // Event
    event Transfer(
        address indexed contractAddress, 
        address indexed from,
        address indexed to,
        uint256 amount
    );


    /**
     * @dev A modifier that allows both owner and beneficiary (when owner isDead) to access to the method
     */
    modifier onlyAllowWithdrawal() {
        require(msg.sender == owner() || (msg.sender == beneficiary() && isDead()), "Required permission");
        _;
    }

    constructor(uint256 _blockThreshold, address payable _beneficiaryAccount) Ownership(_beneficiaryAccount)
        public
    {
        lastCheckInBlock = block.number;
        blockThreshold = _blockThreshold;
    }


    /**
     * @dev For Owner to prove alive
     */
    function proveAlive() public onlyOwner {
        lastCheckInBlock = block.number;
    }

    /**
     * @dev For Owner to update the threshold of the block
     */
    function updateBlockThreshold(uint256 _blockThreshold) public onlyOwner {
        lastCheckInBlock = block.number;
        blockThreshold = _blockThreshold;
    }

    /**
     * @dev DeadManSwitch concept of proving alive, when the blockNumDiff has passed the threshold, return true
     */
    function isDead() public view returns (bool) {
        uint256 blockNumDiff = block.number.sub(lastCheckInBlock);
        return blockNumDiff >= blockThreshold;
    }

    /**
     * @dev allow Owner to send ether
     */
    function sendFunds(address _destination,  uint256 _amount, bytes calldata _data) external onlyOwner {
        (bool success, ) = _destination.call.value(_amount)(_data);
        require(success, "[sendFunds] Transfer failure");
        emit Transfer(
            address(0),
            address(this),
            _destination,
            _amount
        );
    }

    /** 
     * @dev withdraw ether
     */
    function withdrawEther(uint256 _amount) external onlyAllowWithdrawal {
        address payable self = address(this);
        require(_amount <= self.balance, "Insufficient balance in the contract.");
        (bool success, ) = msg.sender.call.value(_amount)("");
        require(success, "[claim] Tranfer failed");
        emit Transfer(
            address(0),
            address(this),
            msg.sender,
            _amount
        );
    }

    /**
     * @dev Allow deposit of ERC20 with the prerequisite of allowance, need to call `approve()` in ERC20 contract before using this
     */
    function depositERC20(address _contractAddress, uint256 _amount) external {
        IERC20 token = IERC20(_contractAddress);
        address self = address(this);
        require(_amount <= token.balanceOf(msg.sender), "Insufficient balance.");
        require(_amount <= token.allowance(msg.sender, self), "Insufficient allowance.");
        require(token.transferFrom(msg.sender, self, _amount), "Cannot transfer ERC20 token");
        assert(token.balanceOf(self) >= _amount);
        emit Transfer(
            _contractAddress,
            msg.sender,
            address(this),
            _amount
        );
    }

    /**
     * @dev Allow withdrawal of ERC20 token for owner or beneficiary (when owner died)
     */
    function withdrawERC20(address _contractAddress, uint256 _amount) external onlyAllowWithdrawal {
        IERC20 token = IERC20(_contractAddress);
        address self = address(this);
        require(_amount <= token.balanceOf(self), "Insufficient balance.");
        require(token.transfer(msg.sender, _amount));
        emit Transfer(
            _contractAddress,
            address(this),
            msg.sender,
            _amount
        );
    }

    function destroy() external onlyOwner {
		selfdestruct(msg.sender);
	}

    /** 
     * @dev Allow contract to receive any eth
     */
    receive() external payable {
        emit Transfer(
            address(0),
            msg.sender,
            address(this),
            msg.value
        );
    }

}
