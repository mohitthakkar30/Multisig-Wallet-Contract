// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AccessControl {
    using SafeMath for uint256;

    /**
     * Events
     */
    event Deposit(address indexed sender, uint256 value);
    event Submission(uint256 indexed transactionId);
    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);
    event Revocation(address indexed sender, uint256 indexed transactionId);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event QuorumUpdate(uint256 quorum);
    event AdminTransfer(address indexed newAdmin);

    /**
     * Storage
     */
    address public admin;

    // track addresses of owners
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 quorum;

    /**
     * Modifiers
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Admin restricted function");
        _;
    }

    modifier notNull(address _address) {
        require(_address != address(0), "Specified destination doesn't exist");
        _;
    }

    modifier ownerExistsMod(address owner) {
        require(isOwner[owner] == true, "This owner doesn't exist");
        _;
    }

    modifier notOwnerExistsMod(address owner) {
        require(isOwner[owner] == false, "This owner already exists");
        _;
    }

    /**
     * @dev Contract constructor instantiates wallet interface and sets msg.sender to admin
     */
    constructor(address[] memory _owners) {
        admin = msg.sender;
        require(
            _owners.length >= 3,
            "There need to be atleast 3 initial signatories for this wallet"
        );
        for (uint256 i = 0; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        uint256 num = SafeMath.mul(owners.length, 60);
        quorum = SafeMath.div(num, 100);
    }

    /**
     * Public Functions
     */

    /**
     * @dev Allows admin to add new owner to the wallet
     * @param owner Address of the new owner
     */
    function addOwner(address owner)
        public
        onlyAdmin
        notNull(owner)
        notOwnerExistsMod(owner)
    {
        // add owner
        isOwner[owner] = true;
        owners.push(owner);

        // emit event
        emit OwnerAddition(owner);

        // update quorum
        updateQuorum(owners);
    }

    /**
     * @dev Allows admin to remove owner from the wallet
     * @param owner Address of the new owner
     */
    function removeOwner(address owner)
        public
        onlyAdmin
        notNull(owner)
        ownerExistsMod(owner)
    {
        // remove owner
        isOwner[owner] = false;

        // ite6rate over owners and remove the current owner
        for (uint256 i = 0; i < owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.pop();

        // update quorum
        updateQuorum(owners);
    }

    /**
     * @dev Allows admin to transfer owner from one wallet to  another
     * @param _from Address of the old owner
     * @param _to Address of the new owner
     */
    function transferOwner(address _from, address _to)
        public
        onlyAdmin
        notNull(_from)
        notNull(_to)
        ownerExistsMod(_from)
        notOwnerExistsMod(_to)
    {
        // iterate over owners
        for (uint256 i = 0; i < owners.length; i++)
            // if the curernt owner
            if (owners[i] == _from) {
                // replace with new owner address
                owners[i] = _to;
                break;
            }

        // reset owner addresses
        isOwner[_from] = false;
        isOwner[_to] = true;

        // emit events
        emit OwnerRemoval(_from);
        emit OwnerAddition(_to);
    }

    /**
     * @dev Allows admin to transfer admin rights to another address
     * @param newAdmin Address of the new admin
     */
    function renounceAdmin(address newAdmin) public onlyAdmin {
        admin = newAdmin;

        emit AdminTransfer(newAdmin);
    }

    /**
     * Internal Functions
     */

    /**
     * @dev Updates the new quorum value
     * @param _owners List of address of the owners
     */
    function updateQuorum(address[] memory _owners) internal {
        uint256 num = SafeMath.mul(_owners.length, 60);
        quorum = SafeMath.div(num, 100);

        emit QuorumUpdate(quorum);
    }
}
