// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;


contract fundMe{
    address public owner;
    struct  parameters{
        string description;
        address owner;
        uint amount;
        uint goalAmount;
        uint minValue;
        uint deadline;
    }
    mapping(uint => parameters) Founds;

    uint public noOfFound;
    
    function setFound(string memory _goal, uint _goalAmount, uint _minVal, uint _deadline) public{
        parameters storage newFound = Founds[noOfFound];
        noOfFound++;

        newFound.description = _goal;
        newFound.owner = msg.sender;
        newFound.goalAmount = _goalAmount;
        newFound.minValue = _minVal;
        newFound.deadline = block.timestamp + _deadline;
    }

    function fund(uint _no) public payable{
        require(msg.value >= Founds[_no].minValue, "To little value.");
        require(block.timestamp < Founds[_no].deadline);
        Founds[_no].amount += msg.value;
    }


    function finalizeFund(uint _no) public {
        require(msg.sender == Founds[_no].owner);
        payable(Founds[_no].owner).transfer(Founds[_no].amount);
    }


    function getBalance(uint _no) public view returns(uint){
        return Founds[_no].amount;
    }

    function getDescription(uint _no) public view returns(string memory){
        return Founds[_no].description;
    }
}
