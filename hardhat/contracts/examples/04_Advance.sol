// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Advanced Solidity Concepts
 * @dev Learn inheritance, modifiers, interfaces, and Ether handling
 *
 * KEY CONCEPTS COVERED:
 * - Constructors and initialization
 * - Function modifiers
 * - Inheritance (single and multiple)
 * - Abstract contracts
 * - Interfaces
 * - Function overriding and virtual functions
 * - Payable functions and Ether transfers
 * - Fallback and receive functions
 */

// ============================================
// ABSTRACT CONTRACTS
// ============================================

/**
 * Abstract contracts have at least one unimplemented function
 * Cannot be deployed directly, must be inherited
 */
abstract contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "New owner is zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // Abstract function - must be implemented by child
    function getOwnerInfo() public view virtual returns (string memory);
}

/**
 * Abstract contract for pausable functionality
 */
abstract contract Pausable {
    bool public paused;

    event Paused(address account);
    event Unpaused(address account);

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

    function _pause() internal whenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal whenPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }
}

// ============================================
// INTERFACES
// ============================================

/**
 * Interfaces define a contract's external structure
 * - All functions must be external
 * - Cannot have state variables
 * - Cannot have constructor
 * - Cannot inherit from other contracts (only interfaces)
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * Custom interface example
 */
interface IVault {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function getBalance(address user) external view returns (uint256);
}

// ============================================
// INHERITANCE (Single and Multiple)
// ============================================

/**
 * Base contract for common functionality
 */
contract Base1 {
    uint256 public value1;

    event ValueUpdated(uint256 oldValue, uint256 newValue);

    function setValue1(uint256 _value) public virtual {
        uint256 oldValue = value1;
        value1 = _value;
        emit ValueUpdated(oldValue, _value);
    }

    function getValue1() public view virtual returns (uint256) {
        return value1;
    }
}

/**
 * Another base contract
 */
contract Base2 {
    uint256 public value2;

    function setValue2(uint256 _value) public virtual {
        value2 = _value;
    }

    function getValue2() public view virtual returns (uint256) {
        return value2;
    }
}

/**
 * Multiple inheritance
 * Order matters: most base-like to most derived
 */
contract MultipleInheritance is Base1, Base2 {
    uint256 public value3;

    // Can access functions from both base contracts
    function setAllValues(uint256 _v1, uint256 _v2, uint256 _v3) public {
        setValue1(_v1);
        setValue2(_v2);
        value3 = _v3;
    }

    function getAllValues() public view returns (uint256, uint256, uint256) {
        return (getValue1(), getValue2(), value3);
    }
}

// ============================================
// FUNCTION OVERRIDING
// ============================================

contract Parent {
    // Virtual function can be overridden
    function greet() public pure virtual returns (string memory) {
        return "Hello from Parent";
    }

    // Not virtual, cannot be overridden
    function staticGreet() public pure returns (string memory) {
        return "Static greeting";
    }
}

contract Child is Parent {
    // Override parent function
    function greet() public pure override returns (string memory) {
        return "Hello from Child";
    }

    // Can call parent version using super
    function greetBoth() public pure returns (string memory, string memory) {
        return (super.greet(), greet());
    }
}

// ============================================
// MODIFIERS
// ============================================

/**
 * Main contract demonstrating all concepts
 */
contract AdvancedContract is Ownable, Pausable {
    // State variables
    mapping(address => uint256) public balances;
    uint256 public totalDeposited;
    uint256 public minimumDeposit = 0.01 ether;

    // Events
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event MinimumDepositChanged(uint256 oldMinimum, uint256 newMinimum);

    // ============================================
    // CUSTOM MODIFIERS
    // ============================================

    /**
     * Modifier to check minimum amount
     */
    modifier minimumAmount(uint256 _amount) {
        require(_amount >= minimumDeposit, "Amount below minimum");
        _; // Continue execution
    }

    /**
     * Modifier with parameters
     */
    modifier validAddress(address _address) {
        require(_address != address(0), "Invalid address");
        _;
    }

    /**
     * Multiple modifiers can be chained
     */
    modifier costs(uint256 price) {
        require(msg.value >= price, "Insufficient payment");
        _;
        // Code after _ executes after function body
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    // ============================================
    // CONSTRUCTOR
    // ============================================

    /**
     * Constructor can call parent constructors
     * Ownable() is called automatically
     */
    constructor() {
        // Custom initialization
        minimumDeposit = 0.01 ether;
    }

    // ============================================
    // IMPLEMENTING ABSTRACT FUNCTION
    // ============================================

    function getOwnerInfo() public view override returns (string memory) {
        return "Advanced Contract Owner";
    }

    // ============================================
    // PAYABLE FUNCTIONS
    // ============================================

    /**
     * Payable allows function to receive Ether
     */
    function deposit() public payable whenNotPaused minimumAmount(msg.value) {
        balances[msg.sender] += msg.value;
        totalDeposited += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    /**
     * Depositing for another address
     */
    function depositFor(
        address _beneficiary
    )
        public
        payable
        whenNotPaused
        validAddress(_beneficiary)
        minimumAmount(msg.value)
    {
        balances[_beneficiary] += msg.value;
        totalDeposited += msg.value;

        emit Deposit(_beneficiary, msg.value);
    }

    // ============================================
    // ETHER TRANSFERS
    // ============================================

    /**
     * Method 1: transfer (2300 gas, reverts on failure)
     * Safest but most limiting
     */
    function withdrawWithTransfer(uint256 _amount) public whenNotPaused {
        require(_amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount); // Reverts on failure

        emit Withdrawal(msg.sender, _amount);
    }

    /**
     * Method 2: send (2300 gas, returns bool)
     * Need to check return value
     */
    function withdrawWithSend(uint256 _amount) public whenNotPaused {
        require(_amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= _amount;
        bool success = payable(msg.sender).send(_amount);
        require(success, "Transfer failed");

        emit Withdrawal(msg.sender, _amount);
    }

    /**
     * Method 3: call (forwards all gas, returns bool and data)
     * Most flexible, recommended for sending Ether
     * Reentrancy protection needed!
     */
    function withdrawWithCall(uint256 _amount) public whenNotPaused {
        require(_amount <= balances[msg.sender], "Insufficient balance");

        // Update state before external call (Checks-Effects-Interactions)
        balances[msg.sender] -= _amount;

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(msg.sender, _amount);
    }

    // ============================================
    // RECEIVE and FALLBACK
    // ============================================

    /**
     * RECEIVE: Called when Ether is sent with empty calldata
     * Must be external payable
     */
    receive() external payable {
        balances[msg.sender] += msg.value;
        totalDeposited += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * FALLBACK: Called when:
     * - Function doesn't exist
     * - Ether sent with data but no receive() exists
     * Can be payable or not
     */
    fallback() external payable {
        // Handle unknown function calls
        // In this example, treat it as a deposit
        balances[msg.sender] += msg.value;
        totalDeposited += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // ============================================
    // ADMIN FUNCTIONS (Using inherited modifiers)
    // ============================================

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setMinimumDeposit(uint256 _minimum) public onlyOwner {
        uint256 oldMinimum = minimumDeposit;
        minimumDeposit = _minimum;
        emit MinimumDepositChanged(oldMinimum, _minimum);
    }

    /**
     * Emergency withdraw (owner only)
     */
    function emergencyWithdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Emergency withdrawal failed");
    }

    // ============================================
    // VIEW FUNCTIONS
    // ============================================

    function getBalance(address _user) public view returns (uint256) {
        return balances[_user];
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMinimumDeposit() public view returns (uint256) {
        return minimumDeposit;
    }
}

// ============================================
// INTERFACE IMPLEMENTATION EXAMPLE
// ============================================

/**
 * Simplified ERC20 implementation
 */
contract SimpleToken is IERC20 {
    string public name = "Simple Token";
    string public symbol = "SMP";
    uint8 public decimals = 18;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(uint256 initialSupply) {
        _totalSupply = initialSupply;
        _balances[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        require(recipient != address(0), "Transfer to zero address");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(_balances[sender] >= amount, "Insufficient balance");
        require(
            _allowances[sender][msg.sender] >= amount,
            "Insufficient allowance"
        );
        require(recipient != address(0), "Transfer to zero address");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }
}

/**
 * WORKSHOP NOTES:
 *
 * INHERITANCE:
 * - Use 'is' keyword to inherit
 * - Multiple inheritance: list from most base to most derived
 * - Override functions with 'override' keyword
 * - Use 'virtual' to allow overriding
 * - Call parent functions with 'super'
 *
 * MODIFIERS:
 * - Reusable code blocks for access control and validation
 * - Execute before/after function body
 * - Can have parameters
 * - Multiple modifiers executed in order
 * - Use underscore _ to mark where function body executes
 *
 * ABSTRACT CONTRACTS:
 * - Have at least one unimplemented function
 * - Cannot be deployed
 * - Used as base contracts
 * - Good for defining interfaces with some implementation
 *
 * INTERFACES:
 * - Only external functions
 * - No implementation
 * - No state variables
 * - Define contract structure
 * - Enable interaction with other contracts
 *
 * ETHER HANDLING:
 * - Use 'payable' to receive Ether
 * - transfer: 2300 gas, reverts on fail
 * - send: 2300 gas, returns bool
 * - call: forwards all gas, most flexible (RECOMMENDED)
 * - receive(): for plain Ether transfers
 * - fallback(): for unknown function calls
 *
 * BEST PRACTICES:
 * - Checks-Effects-Interactions pattern (prevent reentrancy)
 * - Use modifiers for access control
 * - Implement proper inheritance hierarchy
 * - Follow interface standards (ERC20, ERC721, etc.)
 * - Be careful with Ether transfers
 * - Always check return values of send/call
 * - Update state before external calls
 */
