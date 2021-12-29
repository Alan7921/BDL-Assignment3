// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./CustomLib.sol";

contract FundPool{
	
	address public owner;
	mapping (address => bool) registeredAddr; 


	constructor (){
        owner = msg.sender; // assign the address of owner
        registeredAddr[msg.sender] = true;

        emit Registration(msg.sender);
    }

	modifier isOwner() {
        require(msg.sender == owner, "You are not authorized to operate this function.");
        _;
    }

    modifier registered() {
        require(registeredAddr[msg.sender], "You are not authorized to operate this function.");
        _;
    }

    event Registration(address _address);
    event Deposit(address sender, uint256 value);
    event Transfer(address _to, uint256 amount);

	function register(address _address) public isOwner returns (bool isSuccessful) {
		require(!registeredAddr[_address], "This address has been registered");
		registeredAddr[_address] = true;

		emit Registration(_address);
		return true;
	}

	function deposit() public payable registered returns (bool isSuccessful){

		emit Deposit(msg.sender,msg.value);

		return true;
	}

	function transferMoneyTo(address recipient, uint256 amount) public registered returns (bool isSuccessful) {
		require(address(this).balance >= amount, "The fund pool does not have sufficient money now, please wait" 
												 " for the owner to fill.");

		bool success = customLib.customSend(amount,recipient);
		require(success, "Transfer failed.");

		emit Transfer(recipient,amount);

		return true;

	}

	function showBalance() public view returns(uint){
		return address(this).balance;
	}

	function isRegistered(address _address) public view returns(bool){
		return registeredAddr[_address];
	}

}