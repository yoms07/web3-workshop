// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Control Flow and Error Handling
 * @dev Learn conditionals, loops, error handling, and events
 *
 * KEY CONCEPTS COVERED:
 * - If/else statements
 * - Loops (for, while, do-while)
 * - Require, assert, revert
 * - Custom errors (gas efficient)
 * - Events and logging
 * - Ternary operator
 */

contract ControlFlow {
    // ============================================
    // STATE VARIABLES
    // ============================================

    address public owner;
    uint256 public counter;
    bool public isPaused;
    mapping(address => uint256) public balances;

    // ============================================
    // CUSTOM ERRORS (Gas Efficient - Solidity 0.8.4+)
    // ============================================

    error Unauthorized(address caller);
    error InsufficientBalance(uint256 requested, uint256 available);
    error ContractPaused();
    error InvalidAmount();
    error ZeroAddress();

    // ============================================
    // EVENTS (For logging and off-chain tracking)
    // ============================================

    /**
     * Events are stored in transaction logs
     * Indexed parameters can be filtered
     * Max 3 indexed parameters per event
     */
    event Deposit(address indexed user, uint256 amount, uint256 timestamp);
    event Withdrawal(address indexed user, uint256 amount);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event CounterUpdated(uint256 oldValue, uint256 newValue);

    // ============================================
    // CONSTRUCTOR
    // ============================================

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // ============================================
    // IF/ELSE STATEMENTS
    // ============================================

    /**
     * Basic if/else conditional logic
     */
    function checkValue(uint256 _value) public pure returns (string memory) {
        if (_value > 100) {
            return "High value";
        } else if (_value > 50) {
            return "Medium value";
        } else if (_value > 0) {
            return "Low value";
        } else {
            return "Zero value";
        }
    }

    /**
     * Ternary operator (shorthand if/else)
     * condition ? valueIfTrue : valueIfFalse
     */
    function ternaryExample(
        uint256 _value
    ) public pure returns (string memory) {
        return _value > 50 ? "Greater than 50" : "50 or less";
    }

    /**
     * Nested conditionals
     */
    function complexCondition(
        uint256 _value,
        bool _flag
    ) public pure returns (uint256) {
        if (_flag) {
            if (_value > 100) {
                return _value * 2;
            } else {
                return _value + 10;
            }
        } else {
            if (_value > 100) {
                return _value / 2;
            } else {
                return _value - 10;
            }
        }
    }

    // ============================================
    // FOR LOOPS
    // ============================================

    /**
     * Basic for loop
     * WARNING: Be careful with loops - can run out of gas!
     */
    function sumNumbers(uint256 n) public pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i <= n; i++) {
            sum += i;
        }
        return sum;
    }

    /**
     * Loop with early exit (break)
     */
    function findFirstMatch(
        uint256[] memory _numbers,
        uint256 _target
    ) public pure returns (bool found, uint256 index) {
        for (uint256 i = 0; i < _numbers.length; i++) {
            if (_numbers[i] == _target) {
                return (true, i); // Early return
            }
        }
        return (false, 0); // Not found
    }

    /**
     * Loop with continue (skip iteration)
     */
    function sumEvenNumbers(
        uint256[] memory _numbers
    ) public pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < _numbers.length; i++) {
            if (_numbers[i] % 2 != 0) {
                continue; // Skip odd numbers
            }
            sum += _numbers[i];
        }
        return sum;
    }

    /**
     * Reverse loop (sometimes more gas efficient)
     */
    function reverseLoop(uint256 n) public pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = n; i > 0; i--) {
            sum += i;
        }
        return sum;
    }

    // ============================================
    // WHILE LOOPS
    // ============================================

    /**
     * While loop - condition checked before execution
     */
    function whileExample(
        uint256 _start,
        uint256 _limit
    ) public pure returns (uint256) {
        uint256 sum = 0;
        uint256 i = _start;

        while (i <= _limit) {
            sum += i;
            i++;
        }

        return sum;
    }

    /**
     * Do-while loop - executes at least once
     */
    function doWhileExample(uint256 _value) public pure returns (uint256) {
        uint256 result = 0;
        uint256 i = 0;

        do {
            result += i;
            i++;
        } while (i < _value);

        return result;
    }

    // ============================================
    // ERROR HANDLING: REQUIRE
    // ============================================

    /**
     * REQUIRE: Used for input validation and conditions
     * - Refunds remaining gas if fails
     * - Common for checking user inputs, preconditions
     */
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        require(!isPaused, "Contract is paused");

        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    /**
     * Using custom errors with require (more gas efficient)
     */
    function depositWithCustomError() public payable {
        if (msg.value == 0) revert InvalidAmount();
        if (isPaused) revert ContractPaused();

        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    // ============================================
    // ERROR HANDLING: REVERT
    // ============================================

    /**
     * REVERT: Explicitly revert with custom logic
     * Can be used with if statements for complex conditions
     */
    function withdraw(uint256 _amount) public {
        if (_amount == 0) {
            revert InvalidAmount();
        }

        uint256 balance = balances[msg.sender];
        if (_amount > balance) {
            revert InsufficientBalance(_amount, balance);
        }

        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);

        emit Withdrawal(msg.sender, _amount);
    }

    /**
     * Complex validation logic
     */
    function transferOwnership(address _newOwner) public {
        if (msg.sender != owner) {
            revert Unauthorized(msg.sender);
        }

        if (_newOwner == address(0)) {
            revert ZeroAddress();
        }

        address previousOwner = owner;
        owner = _newOwner;

        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    // ============================================
    // ERROR HANDLING: ASSERT
    // ============================================

    /**
     * ASSERT: Used for internal errors and invariants
     * - Should NEVER fail in correct code
     * - Does NOT refund gas (consumes all remaining gas)
     * - Use for checking invariants, internal consistency
     */
    function assertExample(uint256 _value) public {
        uint256 oldCounter = counter;
        counter += _value;

        // Assert that counter increased correctly
        assert(counter >= oldCounter); // Should always be true

        emit CounterUpdated(oldCounter, counter);
    }

    // ============================================
    // TRY/CATCH (External Calls)
    // ============================================

    /**
     * Try/catch for handling external call failures
     * Can only be used with external calls
     */
    function safeDivide(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "Division by zero");
        return a / b;
    }

    function tryCatchExample(
        uint256 a,
        uint256 b
    )
        public
        view
        returns (bool success, uint256 result, string memory errorMessage)
    {
        try this.safeDivide(a, b) returns (uint256 value) {
            return (true, value, "");
        } catch Error(string memory reason) {
            // Catch require/revert with reason string
            return (false, 0, reason);
        } catch (bytes memory) {
            // Catch other errors (including assert, overflow, etc.)
            return (false, 0, "Unknown error");
        }
    }

    // ============================================
    // EVENTS USAGE
    // ============================================

    /**
     * Emitting events for off-chain tracking
     */
    function incrementCounter(uint256 _amount) public {
        uint256 oldValue = counter;
        counter += _amount;

        // Emit event with indexed and non-indexed parameters
        emit CounterUpdated(oldValue, counter);
    }

    /**
     * Multiple events in one transaction
     */
    function complexOperation(uint256 _value) public payable {
        require(msg.value > 0, "Must send Ether");

        emit Deposit(msg.sender, msg.value, block.timestamp);

        uint256 oldCounter = counter;
        counter += _value;

        emit CounterUpdated(oldCounter, counter);
    }

    // ============================================
    // CONTROL FLOW PATTERNS
    // ============================================

    /**
     * Guard pattern - check conditions first
     */
    function guardPattern(uint256 _value) public view returns (uint256) {
        // All checks at the top
        require(!isPaused, "Contract paused");
        require(msg.sender == owner, "Not owner");
        require(_value > 0, "Invalid value");

        // Business logic after guards
        return _value * 2;
    }

    /**
     * Early return pattern
     */
    function earlyReturn(uint256 _value) public pure returns (string memory) {
        if (_value == 0) {
            return "Zero";
        }

        if (_value < 10) {
            return "Small";
        }

        if (_value < 100) {
            return "Medium";
        }

        return "Large";
    }

    // ============================================
    // UTILITY FUNCTIONS
    // ============================================

    function pause() public {
        require(msg.sender == owner, "Not owner");
        isPaused = true;
    }

    function unpause() public {
        require(msg.sender == owner, "Not owner");
        isPaused = false;
    }

    function getBalance(address _user) public view returns (uint256) {
        return balances[_user];
    }

    // Function to receive Ether
    receive() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }
}

/**
 * WORKSHOP NOTES:
 *
 * ERROR HANDLING:
 * - REQUIRE: Input validation, refunds gas on failure
 * - REVERT: Custom error logic, refunds gas
 * - ASSERT: Internal invariants, consumes all gas on failure
 * - Custom Errors: More gas efficient than string messages
 *
 * LOOPS:
 * - Be VERY careful with unbounded loops (gas limits!)
 * - Always consider maximum iterations
 * - Prefer mappings over arrays when possible
 * - Use break/continue for early exit
 *
 * EVENTS:
 * - Indexed parameters are searchable/filterable
 * - Maximum 3 indexed parameters per event
 * - Events are cheaper than storage
 * - Essential for off-chain tracking
 *
 * BEST PRACTICES:
 * - Check conditions early (guard pattern)
 * - Use custom errors (save gas)
 * - Emit events for important state changes
 * - Validate inputs with require
 * - Use assert for invariants only
 * - Avoid unbounded loops
 * - Handle external call failures with try/catch
 */
