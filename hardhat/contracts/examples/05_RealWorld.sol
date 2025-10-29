// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Real World Example: Decentralized Voting System
 * @dev Complete mini-project combining all Solidity concepts
 *
 * FEATURES:
 * - Create proposals with deadlines
 * - Vote on proposals (one vote per address)
 * - Weighted voting based on token holdings
 * - Execute proposals after voting ends
 * - Owner controls and emergency functions
 * - Gas optimization techniques
 * - Security best practices
 *
 * CONCEPTS DEMONSTRATED:
 * - All basic data types and structures
 * - Mappings, arrays, structs, enums
 * - Events and error handling
 * - Modifiers and access control
 * - Time-based logic
 * - Reentrancy protection
 * - Gas optimization patterns
 */

contract DecentralizedVoting {
    // ============================================
    // STATE VARIABLES
    // ============================================

    address public owner;
    bool public paused;
    uint256 public proposalCount;

    // Voting power token (simplified)
    mapping(address => uint256) public votingPower;
    uint256 public totalVotingPower;

    // ============================================
    // ENUMS
    // ============================================

    enum ProposalStatus {
        Pending, // Not yet active
        Active, // Currently voting
        Passed, // Voting ended, passed
        Failed, // Voting ended, failed
        Executed, // Proposal executed
        Cancelled // Cancelled by owner
    }

    enum VoteType {
        Against,
        For,
        Abstain
    }

    // ============================================
    // STRUCTS
    // ============================================

    struct Proposal {
        uint256 id;
        string title;
        string description;
        address proposer;
        uint256 startTime;
        uint256 endTime;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstain;
        ProposalStatus status;
        bool executed;
        mapping(address => bool) hasVoted;
        mapping(address => VoteType) votes;
    }

    struct ProposalInfo {
        uint256 id;
        string title;
        string description;
        address proposer;
        uint256 startTime;
        uint256 endTime;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstain;
        ProposalStatus status;
        bool executed;
    }

    // ============================================
    // STORAGE
    // ============================================

    mapping(uint256 => Proposal) public proposals;
    uint256[] public activeProposalIds;

    // ============================================
    // CONSTANTS (Gas Optimization)
    // ============================================

    uint256 public constant MIN_VOTING_PERIOD = 1 days;
    uint256 public constant MAX_VOTING_PERIOD = 30 days;
    uint256 public constant QUORUM_PERCENTAGE = 20; // 20% of total voting power
    uint256 public constant PASS_THRESHOLD = 50; // 50% of votes

    // ============================================
    // EVENTS
    // ============================================

    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        string title,
        uint256 startTime,
        uint256 endTime
    );

    event Voted(
        uint256 indexed proposalId,
        address indexed voter,
        VoteType voteType,
        uint256 votingPower
    );

    event ProposalStatusChanged(
        uint256 indexed proposalId,
        ProposalStatus oldStatus,
        ProposalStatus newStatus
    );

    event ProposalExecuted(
        uint256 indexed proposalId,
        address indexed executor
    );

    event VotingPowerGranted(address indexed user, uint256 amount);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    // ============================================
    // CUSTOM ERRORS (Gas Efficient)
    // ============================================

    error Unauthorized();
    error ContractPaused();
    error InvalidProposal();
    error ProposalNotActive();
    error AlreadyVoted();
    error NoVotingPower();
    error InvalidVotingPeriod();
    error VotingNotEnded();
    error ProposalAlreadyExecuted();
    error QuorumNotReached();
    error ProposalNotPassed();

    // ============================================
    // MODIFIERS
    // ============================================

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert ContractPaused();
        _;
    }

    modifier validProposal(uint256 _proposalId) {
        if (_proposalId >= proposalCount) revert InvalidProposal();
        _;
    }

    modifier hasVotingPower() {
        if (votingPower[msg.sender] == 0) revert NoVotingPower();
        _;
    }

    // ============================================
    // CONSTRUCTOR
    // ============================================

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);

        // Grant initial voting power to deployer for testing
        votingPower[msg.sender] = 100;
        totalVotingPower = 100;
        emit VotingPowerGranted(msg.sender, 100);
    }

    // ============================================
    // CORE FUNCTIONS
    // ============================================

    /**
     * Create a new proposal
     * @param _title Proposal title
     * @param _description Detailed description
     * @param _votingPeriod Duration in seconds
     */
    function createProposal(
        string memory _title,
        string memory _description,
        uint256 _votingPeriod
    ) public whenNotPaused hasVotingPower returns (uint256) {
        // Validation
        if (
            _votingPeriod < MIN_VOTING_PERIOD ||
            _votingPeriod > MAX_VOTING_PERIOD
        ) {
            revert InvalidVotingPeriod();
        }

        uint256 proposalId = proposalCount++;
        Proposal storage newProposal = proposals[proposalId];

        newProposal.id = proposalId;
        newProposal.title = _title;
        newProposal.description = _description;
        newProposal.proposer = msg.sender;
        newProposal.startTime = block.timestamp;
        newProposal.endTime = block.timestamp + _votingPeriod;
        newProposal.status = ProposalStatus.Active;

        activeProposalIds.push(proposalId);

        emit ProposalCreated(
            proposalId,
            msg.sender,
            _title,
            newProposal.startTime,
            newProposal.endTime
        );

        return proposalId;
    }

    /**
     * Cast a vote on a proposal
     * @param _proposalId ID of the proposal
     * @param _voteType Type of vote (For, Against, Abstain)
     */
    function vote(
        uint256 _proposalId,
        VoteType _voteType
    ) public whenNotPaused validProposal(_proposalId) hasVotingPower {
        Proposal storage proposal = proposals[_proposalId];

        // Checks
        if (proposal.status != ProposalStatus.Active)
            revert ProposalNotActive();
        if (block.timestamp > proposal.endTime) {
            _finalizeProposal(_proposalId);
            revert ProposalNotActive();
        }
        if (proposal.hasVoted[msg.sender]) revert AlreadyVoted();

        // Effects
        uint256 voterPower = votingPower[msg.sender];
        proposal.hasVoted[msg.sender] = true;
        proposal.votes[msg.sender] = _voteType;

        if (_voteType == VoteType.For) {
            proposal.votesFor += voterPower;
        } else if (_voteType == VoteType.Against) {
            proposal.votesAgainst += voterPower;
        } else {
            proposal.votesAbstain += voterPower;
        }

        emit Voted(_proposalId, msg.sender, _voteType, voterPower);
    }

    /**
     * Finalize a proposal after voting period
     * Can be called by anyone
     */
    function finalizeProposal(
        uint256 _proposalId
    ) public validProposal(_proposalId) {
        _finalizeProposal(_proposalId);
    }

    /**
     * Internal function to finalize proposal
     */
    function _finalizeProposal(uint256 _proposalId) private {
        Proposal storage proposal = proposals[_proposalId];

        if (proposal.status != ProposalStatus.Active) return;
        if (block.timestamp <= proposal.endTime) revert VotingNotEnded();

        ProposalStatus oldStatus = proposal.status;

        // Calculate results
        uint256 totalVotes = proposal.votesFor +
            proposal.votesAgainst +
            proposal.votesAbstain;
        uint256 quorum = (totalVotingPower * QUORUM_PERCENTAGE) / 100;

        if (totalVotes < quorum) {
            proposal.status = ProposalStatus.Failed;
        } else {
            uint256 votesNeededToPass = ((proposal.votesFor +
                proposal.votesAgainst) * PASS_THRESHOLD) / 100;

            if (proposal.votesFor > votesNeededToPass) {
                proposal.status = ProposalStatus.Passed;
            } else {
                proposal.status = ProposalStatus.Failed;
            }
        }

        emit ProposalStatusChanged(_proposalId, oldStatus, proposal.status);
    }

    /**
     * Execute a passed proposal
     * In real systems, this would trigger actual on-chain actions
     */
    function executeProposal(
        uint256 _proposalId
    ) public onlyOwner validProposal(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];

        // Finalize if not already done
        if (
            proposal.status == ProposalStatus.Active &&
            block.timestamp > proposal.endTime
        ) {
            _finalizeProposal(_proposalId);
        }

        if (proposal.status != ProposalStatus.Passed)
            revert ProposalNotPassed();
        if (proposal.executed) revert ProposalAlreadyExecuted();

        proposal.executed = true;
        proposal.status = ProposalStatus.Executed;

        emit ProposalExecuted(_proposalId, msg.sender);
        emit ProposalStatusChanged(
            _proposalId,
            ProposalStatus.Passed,
            ProposalStatus.Executed
        );

        // In a real system, execute the proposal actions here
    }

    // ============================================
    // VIEW FUNCTIONS
    // ============================================

    /**
     * Get proposal details
     */
    function getProposal(
        uint256 _proposalId
    ) public view validProposal(_proposalId) returns (ProposalInfo memory) {
        Proposal storage p = proposals[_proposalId];

        return
            ProposalInfo({
                id: p.id,
                title: p.title,
                description: p.description,
                proposer: p.proposer,
                startTime: p.startTime,
                endTime: p.endTime,
                votesFor: p.votesFor,
                votesAgainst: p.votesAgainst,
                votesAbstain: p.votesAbstain,
                status: p.status,
                executed: p.executed
            });
    }

    /**
     * Check if user has voted on a proposal
     */
    function hasVoted(
        uint256 _proposalId,
        address _voter
    ) public view validProposal(_proposalId) returns (bool) {
        return proposals[_proposalId].hasVoted[_voter];
    }

    /**
     * Get user's vote on a proposal
     */
    function getUserVote(
        uint256 _proposalId,
        address _voter
    ) public view validProposal(_proposalId) returns (VoteType) {
        if (!proposals[_proposalId].hasVoted[_voter]) {
            revert("User has not voted");
        }
        return proposals[_proposalId].votes[_voter];
    }

    /**
     * Get all active proposal IDs
     */
    function getActiveProposals() public view returns (uint256[] memory) {
        uint256 activeCount = 0;

        // Count active proposals
        for (uint256 i = 0; i < activeProposalIds.length; i++) {
            uint256 proposalId = activeProposalIds[i];
            if (proposals[proposalId].status == ProposalStatus.Active) {
                activeCount++;
            }
        }

        // Create array of active proposals
        uint256[] memory active = new uint256[](activeCount);
        uint256 index = 0;

        for (uint256 i = 0; i < activeProposalIds.length; i++) {
            uint256 proposalId = activeProposalIds[i];
            if (proposals[proposalId].status == ProposalStatus.Active) {
                active[index] = proposalId;
                index++;
            }
        }

        return active;
    }

    /**
     * Calculate if quorum is reached
     */
    function isQuorumReached(
        uint256 _proposalId
    ) public view validProposal(_proposalId) returns (bool) {
        Proposal storage proposal = proposals[_proposalId];
        uint256 totalVotes = proposal.votesFor +
            proposal.votesAgainst +
            proposal.votesAbstain;
        uint256 quorum = (totalVotingPower * QUORUM_PERCENTAGE) / 100;
        return totalVotes >= quorum;
    }

    // ============================================
    // ADMIN FUNCTIONS
    // ============================================

    /**
     * Grant voting power to users (simplified token system)
     */
    function grantVotingPower(address _user, uint256 _amount) public onlyOwner {
        votingPower[_user] += _amount;
        totalVotingPower += _amount;

        emit VotingPowerGranted(_user, _amount);
    }

    /**
     * Cancel a proposal (owner only)
     */
    function cancelProposal(
        uint256 _proposalId
    ) public onlyOwner validProposal(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];
        ProposalStatus oldStatus = proposal.status;

        require(
            proposal.status == ProposalStatus.Active ||
                proposal.status == ProposalStatus.Pending,
            "Cannot cancel finalized proposal"
        );

        proposal.status = ProposalStatus.Cancelled;

        emit ProposalStatusChanged(
            _proposalId,
            oldStatus,
            ProposalStatus.Cancelled
        );
    }

    /**
     * Pause contract
     */
    function pause() public onlyOwner {
        paused = true;
    }

    /**
     * Unpause contract
     */
    function unpause() public onlyOwner {
        paused = false;
    }

    /**
     * Transfer ownership
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner is zero address");

        address oldOwner = owner;
        owner = _newOwner;

        emit OwnershipTransferred(oldOwner, _newOwner);
    }
}

/**
 * ============================================
 * WORKSHOP NOTES & BEST PRACTICES
 * ============================================
 *
 * GAS OPTIMIZATION TECHNIQUES:
 * 1. Use constants for fixed values
 * 2. Pack storage variables efficiently
 * 3. Use events instead of storing historical data
 * 4. Cache storage variables in memory
 * 5. Use custom errors instead of require strings
 * 6. Batch operations when possible
 * 7. Use uint256 (native word size)
 * 8. Avoid loops over unbounded arrays
 *
 * SECURITY BEST PRACTICES:
 * 1. Checks-Effects-Interactions pattern
 * 2. Use modifiers for access control
 * 3. Validate all inputs
 * 4. Be careful with timestamps (block.timestamp)
 * 5. Avoid delegatecall unless necessary
 * 6. Use OpenZeppelin libraries
 * 7. Get professional audits
 * 8. Implement emergency pause functionality
 * 9. Use reentrancy guards for external calls
 * 10. Follow established standards (ERC20, ERC721, etc.)
 *
 * CODE ORGANIZATION:
 * 1. Group by functionality
 * 2. State variables at top
 * 3. Events after state variables
 * 4. Modifiers before functions
 * 5. Constructor early
 * 6. External functions before public
 * 7. View/pure functions at end
 * 8. Use meaningful names
 * 9. Comment complex logic
 * 10. Follow style guide (Solidity docs)
 *
 * COMMON PITFALLS TO AVOID:
 * 1. Reentrancy attacks
 * 2. Integer overflow/underflow (pre-0.8.0)
 * 3. Unchecked external calls
 * 4. Timestamp dependence
 * 5. Gas limit issues in loops
 * 6. Uninitialized storage pointers
 * 7. Front-running vulnerabilities
 * 8. Access control issues
 * 9. Delegatecall to untrusted contracts
 * 10. Exposed private data
 *
 * TESTING CHECKLIST:
 * - [ ] Unit tests for all functions
 * - [ ] Edge cases (zero values, max values)
 * - [ ] Access control tests
 * - [ ] Failure scenarios
 * - [ ] Gas optimization tests
 * - [ ] Integration tests
 * - [ ] Fuzz testing
 * - [ ] Security audit
 *
 * DEPLOYMENT CHECKLIST:
 * - [ ] Remove debug code
 * - [ ] Set correct compiler version
 * - [ ] Optimize compiler settings
 * - [ ] Verify source code
 * - [ ] Test on testnet
 * - [ ] Prepare documentation
 * - [ ] Set up monitoring
 * - [ ] Plan upgrade strategy (if needed)
 *
 * FURTHER LEARNING:
 * - OpenZeppelin Contracts
 * - Solidity by Example
 * - Smart Contract Security
 * - DeFi protocols source code
 * - Ethernaut challenges
 * - Capture the Ether
 * - Trail of Bits resources
 */
