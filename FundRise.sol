// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract fundMe{

    using SafeMathChainlink for uint256;

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

    function getEthPrice() public view returns(int256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) =  priceFeed.latestRoundData(); 
        return answer/10**8;
    }
    
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
        Founds[_no].amount = 0;
    }


    function getParams(uint _no) public view returns(string memory, uint, uint){
        return (Founds[_no].description, Founds[_no].amount, Founds[_no].deadline);
    }


    function getVersion() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
}
