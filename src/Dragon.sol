// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ICodex {
    function baseMaxHealth() external view returns (uint);
    function baseHealthRegen() external view returns (uint);
    function baseDamage() external view returns (uint);
    function baseAttackCooldown() external view returns (uint);
    function statsDecay() external view returns (uint);
    function healthPenalty() external view returns (uint);
}

interface ILair {
    function isAuthorized(address _user) external view returns (bool);
    function onFeed(address caller) external;
    function onClean(address caller) external;
    function onPlay(address caller) external;
    function onSleep(address caller) external;
    function onAttack(address caller, address target) external;
    function onProposeBreeding(address caller, address target, string memory name) external;
    function onAcceptBreeding(address caller, address target) external;
    function codex() external view returns (ICodex);
}

contract Dragon {

    string public name;
    address[2] public parents;
    ILair public immutable lair;
    uint public childrenCount;
    uint _health;
    uint _hunger;
    uint _uncleanliness;
    uint _boredom;
    uint _sleepiness;

    uint public lastAttackTime = block.timestamp;
    uint public lastBreedingTime = block.timestamp;
    uint public lastHealthUpdate = block.timestamp;
    uint public lastFeedTime = block.timestamp;
    uint public lastCleanTime = block.timestamp;
    uint public lastPlayTime = block.timestamp;
    uint public lastSleepTime = block.timestamp;

    struct Buff {
        uint amount;
        uint startTime;
        uint endTime;
    }

    Buff public maxHealthBuff;
    Buff public damageBuff;
    Buff public attackCooldownBuff;
    Buff public invulnerableBuff;
    
    Buff public maxHealthDebuff;
    Buff public damageDebuff;
    Buff public attackCooldownDebuff;
    Buff public stunDebuff;

    mapping(address => uint) public loyalty;

    constructor(string memory _name, address[2] memory _parents) {
        lair = ILair(msg.sender);
        name = _name;
        parents = _parents;
        _health = lair.codex().baseMaxHealth();
    }

    modifier updateStats() {
        _health = health();
        lastHealthUpdate = block.timestamp;
        _;
    }

    modifier ifAlive() {
        require(_health > 0, "Dragon: dead");
        _;
    }

    modifier onlyAuthorized() {
        require(lair.isAuthorized(msg.sender), "Dragon: not authorized");
        _;
    }

    function calcBuffs(uint base, Buff storage buff, Buff storage debuff) internal view returns (uint result) {
        result = base;
        if (buff.amount > 0 && buff.startTime < block.timestamp && buff.endTime > block.timestamp) {
            result += buff.amount;
        }
        if (debuff.amount > 0 && debuff.startTime < block.timestamp && debuff.endTime > block.timestamp) {
            if(debuff.amount > result) {
                result = 0;
            } else {
                result -= debuff.amount;
            }
        }
    }

    function healthRegen() public view returns (uint regen) {
        return lair.codex().baseHealthRegen();
    }

    function healthDecay() public view returns (uint decay) {
        if (hunger() == 1_000_000) {
            decay += lair.codex().healthPenalty();
        }
        if (uncleanliness() == 1_000_000) {
            decay += lair.codex().healthPenalty();
        }
        if (boredom() == 1_000_000) {
            decay += lair.codex().healthPenalty();
        }
        if (sleepiness() == 1_000_000) {
            decay += lair.codex().healthPenalty();
        }
    }

    function maxHealth() public view returns (uint max) {
        return calcBuffs(lair.codex().baseMaxHealth(), maxHealthBuff, maxHealthDebuff);
    }

    function damage() public view returns (uint dmg) {
        return calcBuffs(lair.codex().baseDamage(), damageBuff, damageDebuff);
    }

    function attackCooldown() public view returns (uint cooldown) {
        return calcBuffs(lair.codex().baseAttackCooldown(), attackCooldownBuff, attackCooldownDebuff);
    }

    function stunned() public view returns (bool) {
        return stunDebuff.amount > 0 && stunDebuff.startTime < block.timestamp && stunDebuff.endTime > block.timestamp;
    }

    function invulnerable() public view returns (bool) {
        return invulnerableBuff.amount > 0 && invulnerableBuff.startTime < block.timestamp && invulnerableBuff.endTime > block.timestamp;
    }

    function health() public view returns (uint) {
        uint regen = healthRegen();
        uint timeElapsed = block.timestamp - lastHealthUpdate;
        if(timeElapsed == 0) return _health > maxHealth() ? maxHealth() : _health;
        uint regenAmount = regen * timeElapsed;
        uint decayAmount = healthDecay() * timeElapsed;
        if (_health + regenAmount < decayAmount) {
            return 0;
        }
        if (_health + regenAmount - decayAmount > maxHealth()) {
            return maxHealth();
        }
        return _health + regenAmount - decayAmount;
    }

    function hunger() public view returns (uint) {
        uint currHunger = _hunger + (block.timestamp - lastFeedTime) * lair.codex().statsDecay();
        return currHunger > 100 ? 100 : currHunger;
    }

    function uncleanliness() public view returns (uint) {
        uint currUncleanliness = _uncleanliness + (block.timestamp - lastCleanTime) * lair.codex().statsDecay();
        return currUncleanliness > 100 ? 100 : currUncleanliness;
    }

    function boredom() public view returns (uint) {
        uint currBoredom = _boredom + (block.timestamp - lastPlayTime) * lair.codex().statsDecay();
        return currBoredom > 100 ? 100 : currBoredom;
    }

    function sleepiness() public view returns (uint) {
        uint currSleepiness = _sleepiness + (block.timestamp - lastSleepTime) * lair.codex().statsDecay();
        return currSleepiness > 100 ? 100 : currSleepiness;
    }

    function setHealth(uint newHealth) public onlyAuthorized updateStats {
        _health = newHealth;
    }

    function setHunger(uint newHunger) public onlyAuthorized updateStats {
        _hunger = newHunger > 100 ? 100 : newHunger;
        lastFeedTime = block.timestamp;
    }

    function setUncleanliness(uint newUncleanliness) public onlyAuthorized updateStats {
        _uncleanliness = newUncleanliness > 100 ? 100 : newUncleanliness;
        lastCleanTime = block.timestamp;
    }

    function setBoredom(uint newBoredom) public onlyAuthorized updateStats {
        _boredom = newBoredom > 100 ? 100 : newBoredom;
        lastPlayTime = block.timestamp;
    }

    function setSleepiness(uint newSleepiness) public onlyAuthorized updateStats {
        _sleepiness = newSleepiness > 100 ? 100 : newSleepiness;
        lastSleepTime = block.timestamp;
    }

    function setMaxHealthBuff(uint amount, uint startTime, uint endTime) public onlyAuthorized updateStats {
        maxHealthBuff.amount = amount;
        maxHealthBuff.startTime = startTime;
        maxHealthBuff.endTime = endTime;
    }

    function setDamageBuff(uint amount, uint startTime, uint endTime) public onlyAuthorized updateStats {
        damageBuff.amount = amount;
        damageBuff.startTime = startTime;
        damageBuff.endTime = endTime;
    }

    function setAttackCooldownBuff(uint amount, uint startTime, uint endTime) public onlyAuthorized updateStats {
        attackCooldownBuff.amount = amount;
        attackCooldownBuff.startTime = startTime;
        attackCooldownBuff.endTime = endTime;
    }

    function setMaxHealthDebuff(uint amount, uint startTime, uint endTime) public onlyAuthorized updateStats {
        maxHealthDebuff.amount = amount;
        maxHealthDebuff.startTime = startTime;
        maxHealthDebuff.endTime = endTime;
    }

    function setDamageDebuff(uint amount, uint startTime, uint endTime) public onlyAuthorized updateStats {
        damageDebuff.amount = amount;
        damageDebuff.startTime = startTime;
        damageDebuff.endTime = endTime;
    }

    function setAttackCooldownDebuff(uint amount, uint startTime, uint endTime) public onlyAuthorized updateStats {
        attackCooldownDebuff.amount = amount;
        attackCooldownDebuff.startTime = startTime;
        attackCooldownDebuff.endTime = endTime;
    }

    function setStunDebuff(uint amount, uint startTime, uint endTime) public onlyAuthorized updateStats {
        stunDebuff.amount = amount;
        stunDebuff.startTime = startTime;
        stunDebuff.endTime = endTime;
    }

    function setInvulnerableBuff(uint amount, uint startTime, uint endTime) public onlyAuthorized updateStats {
        invulnerableBuff.amount = amount;
        invulnerableBuff.startTime = startTime;
        invulnerableBuff.endTime = endTime;
    }

    function incrementChildrenCount() public onlyAuthorized updateStats {
        childrenCount++;
        lastBreedingTime = block.timestamp;
    }

    function setLoyalty(address user, uint amount) public onlyAuthorized updateStats {
        loyalty[user] = amount;
    }

    function feed() public ifAlive {
        lair.onFeed(msg.sender);
    }

    function clean() public ifAlive {
        lair.onClean(msg.sender);
    }

    function play() public ifAlive {
        lair.onPlay(msg.sender);
    }

    function sleep() public ifAlive {
        lair.onSleep(msg.sender);
    }

    function attack(address target) public ifAlive {
        require(block.timestamp - lastAttackTime >= attackCooldown(), "Dragon: attack on cooldown");
        require(!stunned(), "Dragon: stunned");
        lair.onAttack(msg.sender, target);
        lastAttackTime = block.timestamp;
    }

    function proposeBreeding(address target, string memory _name) public ifAlive {
        lair.onProposeBreeding(msg.sender, target, _name);
    }

    function acceptBreeding(address target) public ifAlive {
        lair.onAcceptBreeding(msg.sender, target);
    }

}