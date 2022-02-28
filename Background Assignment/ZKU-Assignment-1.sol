pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

//Assigment 1
/*
Program a super simple “Hello World” smart contract: store an unsigned integer and then retrieve it. 
Please clearly comment your code. Once completed, deploy the smart contract on Remix. 
Include the .sol file and a screenshot of the Remix UI once deployed in your final submission pdf 
(more info about submission formatting below).
*/

contract Hello_world{
    // Jiggy : An unsigned integer
    uint jiggy = 12;
    //function to retreive the value stored in unsigned integer(jiggy)
    function retrieveJiggy() public view returns(uint){
        return jiggy;
    }
}