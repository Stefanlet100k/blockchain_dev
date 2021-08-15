pragma solidity ^0.7.4;

contract HelloWorld{
    
    string private message = "Hello World!!!";
    
    function getMessage() public view returns(string memory){
        return message;
    }
    
    function setMessage(string memory _message) public {
        message = _message;
    }
}
