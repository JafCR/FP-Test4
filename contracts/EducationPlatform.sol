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
        uint courseIdGenerator;
        mapping (address => UniversityMember) owners;
        mapping (address => UniversityMember) teachers;
        mapping (address => UniversityMember) students;

        mapping (uint => Course) courses; //Mappint to track all classes available for this University
    }

    struct UniversityMember {
        string fullName;
        string email;
        uint id;
        bool active;
    }

    struct Course {
        string courseName;
        uint cost;
        bool active;
        uint activeStudents;
        uint seatsAvailable; //to simulate a student buying multiple seats for a course
        mapping (uint => address) students; //Keeps a list of enrolled students in case we need to send a bulk msg.
    }


    // Events
    event LogUniversityAdded(string name, string desc, uint universityId);
    event LogCourseAdded(string _courseName, uint cost, uint _seatsAvailable, uint courseId);

    // Modifiers
    modifier validAddress(address _address) {
        require(_address != address(0), "ADDRESS CANNOT BE THE ZERO ADDRESS");
        _;
    }

    modifier ownerAtUniversity(uint _universityId) {
        require((universities[_universityId].owners[msg.sender].active == true), "DOES NOT BELONG TO THE UNIVERSITY OWNERS OR IS INACTIVE");
        require(universityOwners.has(msg.sender), "DOES NOT HAVE UNIVERSITY OWNER ROLE");
        _;
    }

    modifier courseIsActive(uint _universityId, uint _courseId) {
        require((universities[_universityId].courses[_courseId].active == true), "COURSE IS INACTIVE - CONTACT UNIVERSITY OWNER");
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

    // Add a Course
    function addCourse(uint _universityId, string memory _courseName, uint _cost, uint _seatsAvailable) public
    ownerAtUniversity(_universityId)
    returns (bool)
    {
        Course memory newCourse;
        newCourse.courseName = _courseName;
        newCourse.seatsAvailable = _seatsAvailable;
        newCourse.cost = _cost;
        newCourse.active = true;
        newCourse.activeStudents = 0;

        uint courseId = universities[_universityId].courseIdGenerator;
        universities[_universityId].courses[courseId] = newCourse;
        universities[_universityId].courseIdGenerator += 1;

        emit LogCourseAdded(_courseName, _cost, _seatsAvailable, courseId);
        return true;
    }

    // Modify a Course
    function updateCourse(uint _universityId, uint _courseId, string memory _courseName, uint _cost, uint _seatsAvailable, bool _isActive)
    public
    ownerAtUniversity(_universityId)
    returns (bool)
    {
        Course memory newCourse;
        newCourse.courseName = _courseName;
        newCourse.seatsAvailable = _seatsAvailable;
        newCourse.cost = _cost;
        newCourse.active = _isActive;
        universities[_universityId].courses[_courseId] = newCourse;
        return true;
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
        newUniversityMember.active = true;
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