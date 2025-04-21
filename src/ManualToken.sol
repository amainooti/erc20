// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

contract ManualToken {
    // myaddress -> 10 tokens
    mapping(address => uint256) private s_balances;
    string public name = "Manual Token";

    function totalSupply() public pure returns (uint256) {
        return 100 ether; // 100 * 10^18
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        //
        uint256 previousBalance = balanceOf(msg.sender) + balanceOf(_to);
        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;

        require(balanceOf(msg.sender) + balanceOf(_to) == previousBalance, "Transfer failed");

        return true;
    }
}
