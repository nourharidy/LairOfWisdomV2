// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Mana {

    uint public maxMana = 1_000_000;
    uint public regenRate = 100;
    address public gm;
    mapping (address => uint) public manaUsage;
    mapping (address => bool) public allowed;
    mapping (address => uint) public lastUpdate;

    constructor() {
        gm = msg.sender;
    }

    modifier applyRegen() {
        uint regen = (block.timestamp - lastUpdate[msg.sender]) * regenRate;
        if (manaUsage[msg.sender] > regen) {
            manaUsage[msg.sender] -= regen;
        } else {
            manaUsage[msg.sender] = 0;
        }
        lastUpdate[msg.sender] = block.timestamp;
        _;
    }

    function mana(address _user) public view returns (uint) {
        uint regen = (block.timestamp - lastUpdate[_user]) * regenRate;
        if (manaUsage[_user] > regen) {
            return maxMana - manaUsage[_user] + regen;
        } else {
            return maxMana;
        }
    }

    function useMana(address user, uint _amount) public applyRegen {
        require(allowed[msg.sender], "Mana: not allowed");
        require(manaUsage[user] + _amount <= maxMana, "Mana: not enough mana");
        manaUsage[user] += _amount;
    }

    function freeMana(address user, uint _amount) public applyRegen {
        require(allowed[msg.sender], "Mana: not allowed");
        if(manaUsage[user] > maxMana) manaUsage[user] = maxMana; // in case the max was lowered
        if(manaUsage[user] < _amount) {
            manaUsage[user] = 0;
        } else {
            manaUsage[user] -= _amount;
        }
    }

    function setMana(address user, uint _amount) public {
        require(allowed[msg.sender], "Mana: not allowed");
        manaUsage[user] = _amount > maxMana ? maxMana : _amount;
    }

    function allow(address _user, bool value) public {
        require(msg.sender == gm, "Mana: not allowed");
        allowed[_user] = value;
    }

    function setGM(address _gm) public {
        require(msg.sender == gm, "Mana: not allowed");
        gm = _gm;
    }

    function setMaxMana(uint _maxMana) public {
        require(msg.sender == gm, "Mana: not allowed");
        maxMana = _maxMana;
    }

}
