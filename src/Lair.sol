// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Codex.sol";
import "./Dragon.sol";
import "./Mana.sol";

contract Lair {

    Codex public codex;
    address public gm;
    Mana public immutable mana;
    mapping(address => bool) public isAuthorized;
    mapping(Dragon => bool) public isDragon;
    mapping (Dragon => mapping(Dragon => string)) public breedProposals;
    Dragon[] public allDragons;


    modifier onlyDragon {
        require(isDragon[Dragon(msg.sender)], "Lair: not a dragon");
        _;
    }

    constructor() {
        codex = new Codex();
        mana = new Mana();
        mana.allow(address(this), true);
        mana.setGM(msg.sender);
        gm = msg.sender;
        

        // create 2 dragons
        address[2] memory parents = [address(0), address(0)];
        createDragon("Dragon 1", parents);
        createDragon("Dragon 2", parents);
    }

    function allDragonsLength() public view returns (uint) {
        return allDragons.length;
    }

    function setGM(address _gm) public {
        require(msg.sender == gm, "Lair: not allowed");
        gm = _gm;
    }

    function _createDragon(string memory name, address[2] memory parents) internal {
        Dragon dragon = new Dragon(name, parents);
        allDragons.push(dragon);
        isDragon[dragon] = true;
    }

    function createDragon(string memory name, address[2] memory parents) public {
        require(isAuthorized[msg.sender], "Lair: not authorized");
        _createDragon(name, parents);
    }

    function authorize(address _user, bool value) public {
        require(msg.sender == gm, "Lair: not allowed");
        isAuthorized[_user] = value;
    }

    function setCodex(address _codex) public {
        require(msg.sender == gm, "Lair: not allowed");
        codex = Codex(_codex);
    }

    function onFeed(address caller) public onlyDragon {
        Dragon dragon = Dragon(msg.sender);
        (uint hunger, uint uncleanliness, uint boredom, uint sleepiness, uint loyalty, uint _mana) = codex.feedEffects(
            dragon,
            caller,
            mana.mana(caller)
        );
        dragon.setHunger(hunger);
        dragon.setUncleanliness(uncleanliness);
        dragon.setBoredom(boredom);
        dragon.setSleepiness(sleepiness);
        dragon.setLoyalty(caller, loyalty);
        mana.setMana(caller, _mana);
    }

    function onClean(address caller) public onlyDragon {
        Dragon dragon = Dragon(msg.sender);
        (uint hunger, uint uncleanliness, uint boredom, uint sleepiness, uint loyalty, uint _mana) = codex.cleanEffects(
            dragon,
            caller,
            mana.mana(caller)
        );
        dragon.setHunger(hunger);
        dragon.setUncleanliness(uncleanliness);
        dragon.setBoredom(boredom);
        dragon.setSleepiness(sleepiness);
        dragon.setLoyalty(caller, loyalty);
        mana.setMana(caller, _mana);
    }

    function onPlay(address caller) public onlyDragon {
        Dragon dragon = Dragon(msg.sender);
        (uint hunger, uint uncleanliness, uint boredom, uint sleepiness, uint loyalty, uint _mana) = codex.playEffects(
            dragon,
            caller,
            mana.mana(caller)
        );
        dragon.setHunger(hunger);
        dragon.setUncleanliness(uncleanliness);
        dragon.setBoredom(boredom);
        dragon.setSleepiness(sleepiness);
        dragon.setLoyalty(caller, loyalty);
        mana.setMana(caller, _mana);
    }

    function onSleep(address caller) public onlyDragon {
        Dragon dragon = Dragon(msg.sender);
        (uint hunger, uint uncleanliness, uint boredom, uint sleepiness, uint loyalty, uint _mana) = codex.sleepEffects(
            dragon,
            caller,
            mana.mana(caller)
        );
        dragon.setHunger(hunger);
        dragon.setUncleanliness(uncleanliness);
        dragon.setBoredom(boredom);
        dragon.setSleepiness(sleepiness);
        dragon.setLoyalty(caller, loyalty);
        mana.setMana(caller, _mana);
    }

    function onAttack(address caller, address target) public onlyDragon {
        Dragon _target = Dragon(target);
        Dragon dragon = Dragon(msg.sender);
        address _caller = caller; // avoid stack too deep
        require(isDragon[_target], "Lair: not a dragon");
        require(_target.health() > 0, "Lair: target is dead");
        require(!_target.invulnerable(), "Lair: target is invulnerable");
        (uint hunger, uint uncleanliness, uint boredom, uint sleepiness, uint loyalty, uint _mana) = codex.attackEffects(dragon, _target, caller, mana.mana(_caller));
        dragon.setHunger(hunger);
        dragon.setUncleanliness(uncleanliness);
        dragon.setBoredom(boredom);
        dragon.setSleepiness(sleepiness);
        dragon.setLoyalty(caller, loyalty);
        mana.setMana(caller, _mana);
        uint targetHealth = _target.health() > dragon.damage() ? _target.health() - dragon.damage() : 0;
        _target.setHealth(targetHealth);
    }

    function onBreedProposal(address caller, address target, string memory name) public onlyDragon {
        Dragon _target = Dragon(target);
        Dragon dragon = Dragon(msg.sender);
        address _caller = caller; // avoid stack too deep
        require(isDragon[_target], "Lair: not a dragon");
        require(_target.health() > 0, "Lair: target is dead");
        (uint hunger, uint uncleanliness, uint boredom, uint sleepiness, uint loyalty, uint _mana) = codex.breedProposalEffects(dragon, _target, caller, mana.mana(_caller));
        dragon.setHunger(hunger);
        dragon.setUncleanliness(uncleanliness);
        dragon.setBoredom(boredom);
        dragon.setSleepiness(sleepiness);
        dragon.setLoyalty(caller, loyalty);
        mana.setMana(caller, _mana);
        breedProposals[dragon][_target] = name;
    }

    function onAcceptBreeding(address caller, address target) public onlyDragon {
        Dragon _target = Dragon(target);
        Dragon dragon = Dragon(msg.sender);
        address _caller = caller; // avoid stack too deep
        require(isDragon[_target], "Lair: not a dragon");
        require(_target.health() > 0, "Lair: target is dead");
        require(bytes(breedProposals[_target][dragon]).length > 0, "Lair: no proposal");
        (uint hunger, uint uncleanliness, uint boredom, uint sleepiness, uint loyalty, uint _mana) = codex.breedAcceptanceEffects(dragon, _target, caller, mana.mana(_caller));
        dragon.setHunger(hunger);
        dragon.setUncleanliness(uncleanliness);
        dragon.setBoredom(boredom);
        dragon.setSleepiness(sleepiness);
        dragon.setLoyalty(caller, loyalty);
        mana.setMana(caller, _mana);
        dragon.incrementChildrenCount();
        _target.incrementChildrenCount();
        _createDragon(breedProposals[_target][dragon], [address(_target), address(dragon)]);
        breedProposals[_target][dragon] = "";
    }

}