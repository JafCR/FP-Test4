pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/*
To use with Remix:
import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/access/Roles.sol";
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol";
*/

contract EducationPlatform is Ownable {

    using Roles for Roles.Role; // We want to use the Roles library
    Roles.Role universityOwners; //Stores University owner Roles
    Roles.Role teachers; // Stores teacher Roles
    Roles.Role students; // Stores student Roles;

    uint public universityIdGenerator;
    mapping (uint => University) public universities; // Mapping to keep track of the Universities

    struct University {
        string name;
        string description;
        string website;
        string phoneNumber;
        bool open;
        uint memberIdGenerator;
        mapping (address => UniversityMember) owners;
        mapping (address => UniversityMember) teachers;
        mapping (address => UniversityMember) students;
    }

    struct UniversityMember {
        string fullName;
        string email;
        uint id;
        bool active;
    }


    // Events
    event LogUniversityAdded(string name, string desc, uint universityId);

    // Modifiers
    modifier validAddress(address _address) {
        require(_address != address(0), "ADDRESS CANNOT BE THE ZERO ADDRESS");
        _;
    }

    modifier ownerAtUniversity(uint universityId) {
        require((universities[universityId].owners[msg.sender].active == true), "DOES NOT BELONG TO THE UNIVERSITY OWNERS OR IS INACTIVE");
        require(universityOwners.has(msg.sender), "DOES NOT HAVE UNIVERSITY OWNER ROLE");
        _;
    }

    // Add Universities
    function addUniversity(string memory _name, string memory _description, string memory _website, string memory _phoneNumber)
    public onlyOwner
    {
        University memory newUniversity;
        newUniversity.name = _name;
        newUniversity.description = _description;
        newUniversity.website = _website;
        newUniversity.phoneNumber = _phoneNumber;
        newUniversity.open = true;
        universities[universityIdGenerator] = newUniversity;
        universityIdGenerator += 1;

        emit LogUniversityAdded(_name, _description, universityIdGenerator);
    }

    // Get University details
    function getUniversity(uint _uniId)
    public view
    returns (string memory name, string memory description, string memory website)
    {
        name = universities[_uniId].name;
        website = universities[_uniId].website;
        description = universities[_uniId].description;
        return (name, description, website);
    }

    /*
    Roles and membership
    */

    function addUniversityOwnerRoles(address _ownerAddr, string memory _fullName, string memory _email, uint universityId)
    public onlyOwner
    validAddress(_ownerAddr)
    {
        universityOwners.add(_ownerAddr);

        UniversityMember memory newUniversityMember;
        newUniversityMember.fullName = _fullName;
        newUniversityMember.email = _email;
        newUniversityMember.id = universities[universityId].memberIdGenerator;
        universities[universityId].owners[_ownerAddr] = newUniversityMember;

        universities[universityId].memberIdGenerator += 1;
    }

    function addUniversityMember(address _addr, string memory _name, string memory _email, uint _universityId, string memory _memberRole) public
    validAddress(_addr)
    ownerAtUniversity(_universityId)
    returns (bool)
    {
        UniversityMember memory newUniversityMember;
        newUniversityMember.fullName = _name;
        newUniversityMember.email = _email;
        newUniversityMember.id = universities[_universityId].memberIdGenerator;
        universities[_universityId].memberIdGenerator += 1;

        if (keccak256(abi.encodePacked(_memberRole)) == keccak256(abi.encodePacked("teacher")))
        {
            teachers.add(_addr);
            universities[_universityId].teachers[_addr] = newUniversityMember;
        }
        else if (keccak256(abi.encodePacked(_memberRole)) == keccak256(abi.encodePacked("student")))
        {
            students.add(_addr);
            universities[_universityId].students[_addr] = newUniversityMember;
        }

        return true;
    }

}