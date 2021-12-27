// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./CustomLib.sol";

contract FundPool{
	
	address owner;
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

	function deposit () public payable registed isOwner returns (bool isSuccessful){

		emit Deposit(msg.sender,msg.value);

		return true;
	}

	function transfer(address recipient, uint256 amount) public registed isOwner returns (bool isSuccessful) {
		require(address(this).balance >= amount, "You do not have enough balance in fund pool now, please deposit more.");

		customLib.customSend(amount,recipient);

		emit Transfer(recipient,amount);

		return true;

	}

	function showBalance() public view returns (uint){
		return address(this).balance;
	}


}