// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./CustomLib.sol";

contract FundPool{
	
	address public owner;
	mapping (address => bool) registedAddr; 

	constructor (){
        owner = msg.sender; // assign the address of owner
    }

	modifier isOwner() {
        require(msg.sender == owner, "You are not authorized to operate this function.");
        _;
    }

    modifier registed() {
        require(contains(msg.sender), "You are not authorized to operate this function.");
        _;
    }


    event Registration(address _address);
    event Deposit(address sender, uint256 value);
    event Transfer(address _to, uint256 amount);

	function register(address _address) public isOwner returns (bool isSuccessful) {
		require(!contains(_address), "This address has been registed");
		registedAddr[_address] = true;

		emit Registration(_address);
		return true;
	}

	function contains(address _address) internal view returns (bool){
		return registedAddr[_address];
	}

	function deposit() public payable registed returns (bool isSuccessful){

		emit Deposit(msg.sender,msg.value);

		return true;
	}

	function transferMoneyTo(address recipient, uint256 amount) public registed returns (bool isSuccessful) {
		require(address(this).balance >= amount, "The fund pool does not have sufficient money now, please wait for filling.");

		customLib.customSend(amount,recipient);

		emit Transfer(recipient,amount);

		return true;

	}

	function showBalance() public view returns (uint){
		return address(this).balance;
	}


}