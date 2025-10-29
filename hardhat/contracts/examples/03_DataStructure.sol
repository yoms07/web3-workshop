// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Data Structures
 * @dev Comprehensive guide to Solidity data structures
 *
 * KEY CONCEPTS COVERED:
 * - Arrays (fixed and dynamic)
 * - Mappings
 * - Structs
 * - Enums
 * - Nested data structures
 * - Storage vs Memory considerations
 */

contract DataStructures {
    // ============================================
    // ARRAYS
    // ============================================

    // Fixed-size array (size cannot change)
    uint256[5] public fixedArray;

    // Dynamic array (size can change)
    uint256[] public dynamicArray;

    // Array of addresses
    address[] public users;

    // Multidimensional array
    uint256[][] public matrix;

    /**
     * Fixed Array Operations
     */
    function fixedArrayOperations() public {
        // Initialize fixed array
        fixedArray[0] = 10;
        fixedArray[1] = 20;
        fixedArray[2] = 30;
        fixedArray[3] = 40;
        fixedArray[4] = 50;

        // Cannot push or pop on fixed arrays
    }

    /**
     * Dynamic Array Operations
     */
    function dynamicArrayOperations() public {
        // Add elements
        dynamicArray.push(100);
        dynamicArray.push(200);
        dynamicArray.push(300);

        // Remove last element
        dynamicArray.pop();

        // Length of array
        uint256 len = dynamicArray.length;

        // Access element
        if (len > 0) {
            uint256 first = dynamicArray[0];
        }

        // Delete element (sets to default value, doesn't reduce length)
        if (dynamicArray.length > 0) {
            delete dynamicArray[0]; // Sets to 0, but array length stays same
        }
    }

    /**
     * Array in Memory
     */
    function createMemoryArray() public pure returns (uint256[] memory) {
        // Memory arrays must have fixed size at creation
        uint256[] memory memArray = new uint256[](5);

        memArray[0] = 1;
        memArray[1] = 2;
        memArray[2] = 3;
        memArray[3] = 4;
        memArray[4] = 5;

        // Cannot push/pop on memory arrays

        return memArray;
    }

    /**
     * Looping through arrays
     */
    function sumArray(uint256[] memory _array) public pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < _array.length; i++) {
            sum += _array[i];
        }
        return sum;
    }

    /**
     * Removing element from array (by shifting)
     */
    function removeAtIndex(uint256 _index) public {
        require(_index < dynamicArray.length, "Index out of bounds");

        // Shift elements left
        for (uint256 i = _index; i < dynamicArray.length - 1; i++) {
            dynamicArray[i] = dynamicArray[i + 1];
        }

        dynamicArray.pop(); // Remove last element
    }

    /**
     * Remove by swapping with last element (gas efficient)
     */
    function removeBySwapping(uint256 _index) public {
        require(_index < dynamicArray.length, "Index out of bounds");

        // Swap with last element
        dynamicArray[_index] = dynamicArray[dynamicArray.length - 1];

        // Remove last element
        dynamicArray.pop();
    }

    // ============================================
    // MAPPINGS
    // ============================================

    /**
     * Mappings are key-value stores
     * - Keys can be any built-in type (no structs, arrays, mappings)
     * - Values can be any type including structs, arrays, mappings
     * - Not iterable (cannot loop through keys)
     * - All keys exist, default values returned for non-set keys
     */

    // Simple mapping
    mapping(address => uint256) public balances;

    // Mapping with complex value
    mapping(address => bool) public isWhitelisted;

    // Nested mapping
    mapping(address => mapping(address => uint256)) public allowances;

    // Mapping to array
    mapping(address => uint256[]) public userScores;

    // Mapping to struct (defined below)
    mapping(address => User) public userDetails;

    /**
     * Basic Mapping Operations
     */
    function mappingOperations() public {
        // Set value
        balances[msg.sender] = 100;

        // Get value
        uint256 balance = balances[msg.sender];

        // Update value
        balances[msg.sender] += 50;

        // Delete (resets to default value)
        delete balances[msg.sender]; // Sets to 0
    }

    /**
     * Nested Mapping Example (like ERC20 allowances)
     */
    function approveAllowance(address _spender, uint256 _amount) public {
        // Owner => Spender => Amount
        allowances[msg.sender][_spender] = _amount;
    }

    function getAllowance(
        address _owner,
        address _spender
    ) public view returns (uint256) {
        return allowances[_owner][_spender];
    }

    /**
     * Mapping with array as value
     */
    function addScore(uint256 _score) public {
        userScores[msg.sender].push(_score);
    }

    function getScores(address _user) public view returns (uint256[] memory) {
        return userScores[_user];
    }

    // ============================================
    // STRUCTS
    // ============================================

    /**
     * Structs group related data together
     */
    struct User {
        string name;
        uint256 age;
        bool isActive;
        address wallet;
    }

    struct Task {
        uint256 id;
        string description;
        bool completed;
        uint256 deadline;
        address assignedTo;
    }

    // Array of structs
    User[] public userList;
    Task[] public tasks;

    /**
     * Creating and Modifying Structs
     */
    function createUser(string memory _name, uint256 _age) public {
        // Method 1: Named parameters
        User memory newUser = User({
            name: _name,
            age: _age,
            isActive: true,
            wallet: msg.sender
        });

        userList.push(newUser);

        // Method 2: Direct push
        userList.push(User(_name, _age, true, msg.sender));

        // Method 3: Storage reference (modify existing)
        User storage user = userDetails[msg.sender];
        user.name = _name;
        user.age = _age;
        user.isActive = true;
        user.wallet = msg.sender;
    }

    /**
     * Reading Struct Data
     */
    function getUserInfo(
        address _userAddress
    )
        public
        view
        returns (string memory name, uint256 age, bool isActive, address wallet)
    {
        User memory user = userDetails[_userAddress];
        return (user.name, user.age, user.isActive, user.wallet);
    }

    /**
     * Modifying Struct in Storage
     */
    function updateUserAge(uint256 _newAge) public {
        User storage user = userDetails[msg.sender];
        user.age = _newAge;
    }

    /**
     * Complex struct operations
     */
    function createTask(
        string memory _description,
        uint256 _deadline,
        address _assignedTo
    ) public returns (uint256) {
        uint256 taskId = tasks.length;

        tasks.push(
            Task({
                id: taskId,
                description: _description,
                completed: false,
                deadline: _deadline,
                assignedTo: _assignedTo
            })
        );

        return taskId;
    }

    function completeTask(uint256 _taskId) public {
        require(_taskId < tasks.length, "Task does not exist");
        Task storage task = tasks[_taskId];
        require(task.assignedTo == msg.sender, "Not assigned to you");

        task.completed = true;
    }

    // ============================================
    // ENUMS
    // ============================================

    /**
     * Enums restrict a variable to one of a few predefined values
     * Useful for state machines and status tracking
     */
    enum Status {
        Pending, // 0
        Approved, // 1
        Rejected, // 2
        Completed // 3
    }

    enum OrderStatus {
        Created,
        Paid,
        Shipped,
        Delivered,
        Cancelled
    }

    // Using enums in state
    Status public contractStatus;
    mapping(uint256 => OrderStatus) public orderStatuses;

    /**
     * Enum Operations
     */
    function setStatus(Status _status) public {
        contractStatus = _status;
    }

    function getStatus() public view returns (Status) {
        return contractStatus;
    }

    function resetStatus() public {
        delete contractStatus; // Resets to first value (Pending)
    }

    /**
     * Enum in struct
     */
    struct Order {
        uint256 id;
        address customer;
        uint256 amount;
        OrderStatus status;
    }

    Order[] public orders;

    function createOrder(uint256 _amount) public returns (uint256) {
        uint256 orderId = orders.length;
        orders.push(
            Order({
                id: orderId,
                customer: msg.sender,
                amount: _amount,
                status: OrderStatus.Created
            })
        );
        return orderId;
    }

    function updateOrderStatus(uint256 _orderId, OrderStatus _status) public {
        require(_orderId < orders.length, "Order does not exist");
        orders[_orderId].status = _status;
    }

    // ============================================
    // NESTED DATA STRUCTURES
    // ============================================

    /**
     * Complex nested structures
     */
    struct Project {
        string name;
        address owner;
        Task[] projectTasks;
        mapping(address => bool) teamMembers;
    }

    // Mapping of mappings with struct
    mapping(uint256 => Project) public projects;
    uint256 public projectCount;

    /**
     * Working with nested structures
     */
    function createProject(string memory _name) public returns (uint256) {
        uint256 projectId = projectCount++;

        Project storage newProject = projects[projectId];
        newProject.name = _name;
        newProject.owner = msg.sender;
        newProject.teamMembers[msg.sender] = true;

        return projectId;
    }

    function addTeamMember(uint256 _projectId, address _member) public {
        Project storage project = projects[_projectId];
        require(project.owner == msg.sender, "Not project owner");

        project.teamMembers[_member] = true;
    }

    function isTeamMember(
        uint256 _projectId,
        address _member
    ) public view returns (bool) {
        return projects[_projectId].teamMembers[_member];
    }

    // ============================================
    // STORAGE vs MEMORY
    // ============================================

    /**
     * Understanding storage vs memory pointers
     */
    function storageVsMemoryExample() public {
        // Create new user in storage
        userDetails[msg.sender] = User("Alice", 25, true, msg.sender);

        // STORAGE reference - modifies blockchain state
        User storage storageUser = userDetails[msg.sender];
        storageUser.age = 26; // This DOES modify blockchain state

        // MEMORY copy - does NOT modify blockchain state
        User memory memoryUser = userDetails[msg.sender];
        memoryUser.age = 30; // This does NOT modify blockchain state

        // After this function, the user's age is 26, not 30
    }

    // ============================================
    // UTILITY FUNCTIONS
    // ============================================

    function getArrayLength() public view returns (uint256) {
        return dynamicArray.length;
    }

    function getAllUsers() public view returns (User[] memory) {
        return userList;
    }

    function getTaskCount() public view returns (uint256) {
        return tasks.length;
    }

    function getOrderCount() public view returns (uint256) {
        return orders.length;
    }
}

/**
 * WORKSHOP NOTES:
 *
 * ARRAYS:
 * - Fixed arrays: size set at declaration
 * - Dynamic arrays: can grow with push(), shrink with pop()
 * - Memory arrays: must be fixed size
 * - delete sets element to default but doesn't reduce length
 * - Be careful with gas costs in loops
 *
 * MAPPINGS:
 * - Key-value storage, very gas efficient
 * - All keys "exist" with default values
 * - Cannot iterate through keys
 * - Cannot get length or check if key exists natively
 * - To track keys, maintain separate array
 * - Delete resets to default value
 *
 * STRUCTS:
 * - Group related data
 * - Can contain any types including arrays and mappings
 * - Storage vs memory matters!
 * - Use storage references to modify state
 * - Use memory for temporary copies
 *
 * ENUMS:
 * - Type-safe way to define states
 * - Stored as uint8 (0, 1, 2, ...)
 * - Good for state machines
 * - Can't have more than 256 values
 *
 * BEST PRACTICES:
 * - Use mappings for lookup by key
 * - Use arrays when you need to iterate
 * - Consider gas costs for large arrays
 * - Use storage references carefully
 * - Structs can't contain themselves
 * - Pack struct variables efficiently (order matters!)
 * - Document complex nested structures
 */
