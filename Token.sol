pragma solidity ^0.4.19;

contract Token {

  // Mapping de balances
  mapping(address => uint256) balances;

  // Total Supply
  uint256 totalSupply;

  // Propietario del Smart Contract
  address public owner;
  
  function Token(uint256 _totalSupply) public {
      totalSupply = _totalSupply;
      owner = msg.sender;
      balances[msg.sender] = totalSupply;
  }
 
  // Devuelve el balance de tokens de una cuenta
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
  
  // Transfiere tokens entre dos cuentas
  function transfer(address _to, uint256 _amount) public returns (bool success) {
    if (balances[msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
      balances[msg.sender] -= _amount;
      balances[_to] += _amount;
        return true;
      } else {
        return false;
      }
   }
}