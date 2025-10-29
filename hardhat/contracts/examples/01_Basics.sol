// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Solidity Basics
 * @dev Introduction to fundamental Solidity concepts and data types
 *
 * KEY CONCEPTS COVERED:
 * - Data types and variables
 * - State variables vs local variables
 * - Memory locations (storage, memory, calldata)
 * - Visibility modifiers
 * - Functions and return values
 * - View and pure functions
 */

contract SolidityBasics {
    // ============================================
    // STATE VARIABLES (stored on blockchain)
    // ============================================

    // Integer types
    uint256 public unsignedInteger = 100; // Unsigned integer (0 to 2^256-1)
    uint8 public smallUint = 255; // 8-bit unsigned (0 to 255)
    int256 public signedInteger = -50; // Signed integer (can be negative)

    // Boolean
    bool public isActive = true;

    // Address types
    address public owner; // Stores Ethereum address (20 bytes)
    address payable public recipient; // Can receive Ether

    // String and Bytes
    string public name = "Web3 Workshop"; // Dynamic string (expensive for storage)
    bytes32 public fixedBytes = "Hello"; // Fixed-size bytes (cheaper)
    bytes public dynamicBytes; // Dynamic bytes array

    // Constants and Immutables (gas efficient)
    uint256 public constant MAX_SUPPLY = 1000000; // Cannot be changed, no storage slot
    uint256 public immutable deployTime; // Set once in constructor

    // ============================================
    // CONSTRUCTOR
    // ============================================

    /**
     * @dev Constructor runs once when contract is deployed
     * Used to initialize state variables
     */
    constructor() {
        owner = msg.sender; // msg.sender = address deploying contract
        deployTime = block.timestamp; // Current block timestamp
        recipient = payable(msg.sender); // Make owner able to receive Ether
    }

    // ============================================
    // VISIBILITY MODIFIERS
    // ============================================

    /**
     * PUBLIC: Accessible from anywhere (internally, externally, derived contracts)
     * Automatically creates a getter function for state variables
     */
    function publicFunction() public pure returns (string memory) {
        return "Anyone can call this";
    }

    /**
     * EXTERNAL: Only callable from outside the contract
     * More gas efficient for external calls
     */
    function externalFunction() external pure returns (string memory) {
        return "Only external calls";
    }

    /**
     * INTERNAL: Only accessible within this contract and derived contracts
     */
    function internalFunction() internal pure returns (string memory) {
        return "Internal access only";
    }

    /**
     * PRIVATE: Only accessible within this contract (not even derived contracts)
     */
    function privateFunction() private pure returns (string memory) {
        return "Private to this contract";
    }

    // Helper to demonstrate calling internal function
    function callInternalFunction() public pure returns (string memory) {
        return internalFunction();
    }

    // ============================================
    // FUNCTION TYPES
    // ============================================

    /**
     * VIEW: Reads state but doesn't modify it
     * No gas cost when called externally
     */
    function getOwner() public view returns (address) {
        return owner;
    }

    /**
     * PURE: Doesn't read or modify state
     * Used for utility functions and calculations
     */
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }

    /**
     * STATE-MODIFYING: Changes blockchain state (costs gas)
     */
    function setName(string memory _newName) public {
        name = _newName; // Modifying state variable
    }

    // ============================================
    // MEMORY LOCATIONS
    // ============================================

    /**
     * STORAGE: Permanent data stored on blockchain (expensive)
     * State variables are always in storage
     */
    string storageString = "I am in storage";

    /**
     * MEMORY: Temporary data, exists during function execution
     * Used for function parameters and local variables
     */
    function memoryExample(
        string memory _tempString
    ) public pure returns (string memory) {
        string memory localString = "Temporary"; // Exists only during function call
        return string(abi.encodePacked(_tempString, " ", localString));
    }

    /**
     * CALLDATA: Read-only, used for function parameters (most gas efficient)
     * Cannot be modified
     */
    function calldataExample(
        string calldata _data
    ) external pure returns (string calldata) {
        // _data cannot be modified, just returned or read
        return _data;
    }

    // ============================================
    // RETURN VALUES
    // ============================================

    /**
     * Single return value
     */
    function getSingleValue() public pure returns (uint256) {
        return 42;
    }

    /**
     * Multiple return values (named)
     */
    function getMultipleValues()
        public
        pure
        returns (uint256 num, string memory text, bool flag)
    {
        num = 100;
        text = "Hello";
        flag = true;
    }

    /**
     * Multiple return values (unnamed)
     */
    function getMultipleValues2()
        public
        pure
        returns (uint256, string memory, bool)
    {
        return (200, "World", false);
    }

    /**
     * Destructuring return values
     */
    function useMultipleReturns() public pure returns (uint256) {
        (uint256 num, , bool flag) = getMultipleValues(); // Skip middle value with empty space
        return flag ? num : 0;
    }

    // ============================================
    // GLOBAL VARIABLES (EVM-provided)
    // ============================================

    /**
     * Important global variables available in EVM
     */
    function getGlobalVariables()
        public
        payable
        returns (
            address sender,
            uint256 value,
            uint256 timestamp,
            uint256 blockNumber,
            uint256 gasLeft
        )
    {
        sender = msg.sender; // Address calling the function
        value = msg.value; // Amount of Ether sent (in wei)
        timestamp = block.timestamp; // Current block timestamp
        blockNumber = block.number; // Current block number
        gasLeft = gasleft(); // Remaining gas
    }

    // ============================================
    // TYPE CONVERSIONS
    // ============================================

    function typeConversions()
        public
        pure
        returns (uint256, int256, address, bytes32)
    {
        // Uint to int
        uint256 u = 100;
        int256 i = int256(u);

        // Address from uint160
        address addr = address(uint160(123456));

        // String to bytes32 (fixed size)
        bytes32 b = bytes32(abi.encodePacked("Hello"));

        return (u, i, addr, b);
    }

    // ============================================
    // MATHEMATICAL OPERATIONS
    // ============================================

    function mathOperations(
        uint256 a,
        uint256 b
    )
        public
        pure
        returns (
            uint256 sum,
            uint256 difference,
            uint256 product,
            uint256 quotient,
            uint256 remainder,
            uint256 power
        )
    {
        sum = a + b;
        difference = a - b; // Will revert if b > a (underflow protection in 0.8.0+)
        product = a * b;
        quotient = a / b; // Integer division (rounds down)
        remainder = a % b;
        power = a ** 2; // a squared

        // Note: Solidity 0.8.0+ has built-in overflow/underflow protection
        // Earlier versions required SafeMath library
    }

    // ============================================
    // COMPARISON AND LOGICAL OPERATORS
    // ============================================

    function comparisons(uint256 a, uint256 b) public pure returns (bool) {
        bool equal = (a == b);
        bool notEqual = (a != b);
        bool greater = (a > b);
        bool less = (a < b);
        bool greaterOrEqual = (a >= b);
        bool lessOrEqual = (a <= b);

        // Logical operators
        bool andResult = (a > 0) && (b > 0); // AND
        bool orResult = (a > 0) || (b > 0); // OR
        bool notResult = !(a > 0); // NOT

        return
            andResult ||
            orResult ||
            notResult ||
            equal ||
            notEqual ||
            greater ||
            less ||
            greaterOrEqual ||
            lessOrEqual;
    }
}

/**
 * WORKSHOP NOTES:
 *
 * 1. STATE VARIABLES cost gas to store and modify
 * 2. Use MEMORY for temporary data in functions
 * 3. Use CALLDATA for read-only function parameters (most efficient)
 * 4. VIEW functions don't cost gas when called externally
 * 5. PURE functions don't access blockchain state at all
 * 6. Always specify visibility modifiers for security
 * 7. Use uint256 as default for numbers (most gas efficient)
 * 8. Constants and immutables save gas
 *
 * SECURITY TIPS:
 * - Always validate inputs
 * - Be careful with overflow (pre-0.8.0 versions)
 * - Use specific Solidity version (avoid ^)
 * - Private doesn't mean secret (blockchain is public)
 */
