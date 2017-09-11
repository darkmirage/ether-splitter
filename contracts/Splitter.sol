pragma solidity ^0.4.0;

contract Splitter {
    mapping(address => uint) balances;
    mapping(address => address[]) payerToPayees;
    
    event SetSplit(address sender, address payeeA, address payeeB);
    event SendPayment(address sender, address payeeA, address payeeB, uint amountEach, uint remainder);
    event WithdrawBalance(address sender, uint amountWithdrawn);
    
    function setSplit(address payeeA, address payeeB) public {
        address[] memory payees = new address[](2);
        payees[0] = payeeA;
        payees[1] = payeeB;
        payerToPayees[msg.sender] = payees;
        SetSplit(msg.sender, payeeA, payeeB);
    }
    
    function sendPayment() public payable {
        var payees = payerToPayees[msg.sender];
        require(payees.length == 2);
        address payeeA = payees[0];
        address payeeB = payees[1];
        uint totalAmount = msg.value;
        uint remainder = 0;
        if (totalAmount % 2 == 1) {
            totalAmount -= 1;
            remainder = 1;
        }
        uint sendAmount = totalAmount / 2;
        balances[payeeA] += sendAmount;
        balances[payeeB] += sendAmount;
        balances[msg.sender] += remainder;
        SendPayment(msg.sender, payeeA, payeeB, sendAmount, remainder);
    }
    
    function withdrawBalance() public {
        uint balance = balances[msg.sender];
        require(balance > 0);
        balances[msg.sender] = 0;
        require(msg.sender.send(balance));
        WithdrawBalance(msg.sender, balance);
    }
    
    function getBalance() public constant returns (uint) {
        return balances[msg.sender];
    }

    function getBalance(address account) public constant returns (uint) {
        return balances[account];
    }
}