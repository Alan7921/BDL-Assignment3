// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./FundPool.sol";

contract token{

	//a uint256 that defines the price of your token in wei;
	//each token can be purchased with tokenPrice wei
	uint256 public tokenPrice;
	//a immutable variable used to record the initial price
	uint256 private immutable INITIAL_PRICE;
	//a uint256 records the amount of the existed token
	uint256 private existAmount;
	//a mapping records the balances of users
	mapping (address => uint256) balances;
	//a address records the creator's address
	address private owner;
	//a address records the fundPool's address 
	FundPool private immutable FUNDPOOL;
	//a bool variable to resist re-entrancy attack
	bool private locked;


	constructor (uint256 initialPrice, address _fundPoolAddr) payable{
        owner = msg.sender; // assign the address of owner
        INITIAL_PRICE = initialPrice;
        tokenPrice = initialPrice;
        FUNDPOOL = FundPool(_fundPoolAddr);
    }

    // Modifier to check that the caller is the owner of the contract.
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized to operate this function.");
        _;
    }

    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }
    
	event Purchase(address buyer, uint256 amount);
	event Transfer(address sender, address receiver, uint256 amount);
	event Sell(address seller, uint256 amount);
	event Price(uint256 price);

	/*	a function via which a user purchases amount number of tokens by paying the equivalent price in wei; 
		if the purchase is successful, the function returns a boolean value (true) 
		and emits an event Purchase with the buyer’s address and the purchased amount
	*/
	function buyToken(uint256 amount) public payable returns (bool isSuccessful) {
		require(msg.value >= tokenPrice*amount,"Insufficient value, please check current price then send enough value.");

		//resist overflow 
		//require (balances[msg.sender] + amount >= balances[msg.sender],"sorry,your balance is full now.");
		//require (existAmount + amount >= existAmount,"sorry,currently the exist token approach its limitation.");

		balances[msg.sender] += amount;
		existAmount += amount;


		bool success = FUNDPOOL.deposit{value:msg.value}();
		require(success,"There is something wrong with the link between token contract and fundPool, "
						"please wait for the owner to handle it.");

		emit Purchase(msg.sender,amount);

		return true;
	}

	/*	a function that transfers amount number of
		tokens from the account of the transaction’s sender to the recipient; if the transfer is
		successful, the function returns a boolean value (true) and emits an event Transfer, with the
		sender’s and receiver’s addresses and the transferred amount
	*/
	function transfer(address recipient, uint256 amount) public returns (bool isSuccessful) {
		require(balances[msg.sender] >= amount, "You do not have enough balance.");

		balances[msg.sender] -= amount;

		//require (balances[recipient] + amount >= balances[recipient],"sorry,the recipient's balance is full now.");
		balances[recipient] += amount;

		emit Transfer(msg.sender,recipient,amount);

		return true;

	}	

	/*	a function via which a user sells amount number of tokens
		and receives from the contract tokenPrice wei for each sold token; if the sell is successful,
		the sold tokens are destroyed, the function returns a boolean value (true) and emits an
		event Sell with the seller’s address and the sold amount of tokens
	*/
	function sellToken(uint256 amount) public noReentrancy returns (bool isSuccessful) {
		//caution: re-entrancy
		require(amount*tokenPrice > 1, "Sorry,the transfer operation would take 1 wei as hand fee,"
									   " thus, you must make sure that the price of the sold token"
									   " is higher then 1 wei.");
		require(balances[msg.sender] >= amount, "Sorry, you do not have enough token in your balance.");
	
		//require(balances[msg.sender] - amount < balances[msg.sender]);
		balances[msg.sender] -= amount;

		//require (existAmount - amount < existAmount);
		existAmount -= amount;

		//make the payment to the customer
		//customLib.customSend(amount*tokenPrice, msg.sender);

		bool success = FUNDPOOL.transferMoneyTo(msg.sender, amount*tokenPrice);
		require(success, "Transfer from fundPool failed.");

		emit Sell(msg.sender, amount);
		return true;
	}		


	/*	a function via which the contract’s creator can change the
		tokenPrice; if the action is successful, the function returns a boolean value (true) and emits
		an event Price with the new price (Note: make sure that, whenever the price changes, the
		contract’s funds suffice so that all tokens can be sold for the updated price)
	*/
	function changePrice(uint256 price) public onlyOwner returns (bool isSuccessful) {
		require(price >= INITIAL_PRICE, "You could not change the price " 
										"to be lower than its initial price.");
		require(fundPool.showBalance() >= existAmount * price, 
			"The fundPool do not have sufficient banlance " 
			"to pay for all the existed token according the price to be changed.");

		tokenPrice = price;

		emit Price(price);

		return true;
	}

	/*
		a view that returns the amount of tokens that the user owns
	*/
	function getBalance() public view returns (uint256){
		return balances[msg.sender];
	}
	
}