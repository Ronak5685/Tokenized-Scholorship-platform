// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ScholarshipToken is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _scholarshipIds;

    // Scholarship structure to store details
    struct Scholarship {
        string institutionName;
        uint256 amount;
        uint256 startDate;
        uint256 endDate;
        address recipient;
        bool isActive;
    }

    // Mapping to store scholarship details
    mapping(uint256 => Scholarship) public scholarships;

    // Events for tracking scholarship creation and status changes
    event ScholarshipCreated(
        uint256 indexed scholarshipId, 
        string institutionName, 
        uint256 amount, 
        address recipient
    );
    event ScholarshipTransferred(
        uint256 indexed scholarshipId, 
        address previousRecipient, 
        address newRecipient
    );
    event ScholarshipStatusChanged(
        uint256 indexed scholarshipId, 
        bool isActive
    );

    // Constructor now takes the initial owner address
    constructor(address _initialOwner) 
        ERC721("ScholarshipToken", "SCHOL") 
        Ownable(_initialOwner) 
    {}

    // Function to create a new scholarship token
    function createScholarship(
        string memory _institutionName,
        uint256 _amount,
        uint256 _startDate,
        uint256 _endDate,
        address _recipient
    ) public onlyOwner returns (uint256) {
        // Increment scholarship ID
        _scholarshipIds.increment();
        uint256 newScholarshipId = _scholarshipIds.current();

        // Mint new scholarship token
        _safeMint(_recipient, newScholarshipId);

        // Create scholarship struct
        scholarships[newScholarshipId] = Scholarship({
            institutionName: _institutionName,
            amount: _amount,
            startDate: _startDate,
            endDate: _endDate,
            recipient: _recipient,
            isActive: true
        });

        // Emit event for scholarship creation
        emit ScholarshipCreated(
            newScholarshipId, 
            _institutionName, 
            _amount, 
            _recipient
        );

        return newScholarshipId;
    }

    // Function to transfer scholarship to a new recipient
    function transferScholarship(
        uint256 _scholarshipId, 
        address _newRecipient
    ) public {
        // Ensure only current recipient can transfer
        require(
            msg.sender == scholarships[_scholarshipId].recipient, 
            "Only current recipient can transfer"
        );

        // Transfer the scholarship token
        _transfer(msg.sender, _newRecipient, _scholarshipId);

        // Update scholarship recipient
        address previousRecipient = scholarships[_scholarshipId].recipient;
        scholarships[_scholarshipId].recipient = _newRecipient;

        // Emit transfer event
        emit ScholarshipTransferred(
            _scholarshipId, 
            previousRecipient, 
            _newRecipient
        );
    }

    // Function to change scholarship status (activate/deactivate)
    function changeScholarshipStatus(
        uint256 _scholarshipId, 
        bool _status
    ) public onlyOwner {
        scholarships[_scholarshipId].isActive = _status;

        // Emit status change event
        emit ScholarshipStatusChanged(_scholarshipId, _status);
    }

    // Function to get scholarship details
    function getScholarshipDetails(uint256 _scholarshipId) 
        public 
        view 
        returns (Scholarship memory) 
    {
        return scholarships[_scholarshipId];
    }
}