// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Dragon.sol";

contract Codex {
    uint constant public baseMaxHealth = 1_000_000;
    uint constant public baseHealthRegen = 10;
    uint constant public baseDamage = 1000;
    uint constant public baseAttackCooldown = 3600; // 1 hour
    uint constant public statsDecay = 100;
    uint constant public healthPenalty = 100;

    function feedEffects(
        Dragon dragon,
        address caller,
        uint mana
    ) public view returns (uint, uint, uint, uint, uint, uint) {
        require(dragon.hunger() > 10, "Codex: not hungry");
        return (
            0,
            dragon.uncleanliness() + 10,
            dragon.boredom(),
            dragon.sleepiness() + 10,
            dragon.loyalty(caller) + 10,
            mana - 1000
        );
    }

    function cleanEffects(
        Dragon dragon,
        address caller,
        uint mana
    ) public view returns (uint, uint, uint, uint, uint, uint) {
        require(dragon.uncleanliness() > 10, "Codex: not dirty");
        return (
            dragon.hunger(),
            0,
            dragon.boredom(),
            dragon.sleepiness() + 10,
            dragon.loyalty(caller) + 10,
            mana - 1000
        );
    }

    function playEffects(
        Dragon dragon,
        address caller,
        uint mana
    ) public view returns (uint, uint, uint, uint, uint, uint) {
        require(dragon.boredom() > 10, "Codex: not bored");
        return (
            dragon.hunger() + 10,
            dragon.uncleanliness(),
            0,
            dragon.sleepiness() + 10,
            dragon.loyalty(caller) + 10,
            mana - 1000
        );
    }

    function sleepEffects(
        Dragon dragon,
        address caller,
        uint mana
    ) public view returns (uint, uint, uint, uint, uint, uint) {
        require(dragon.sleepiness() > 10, "Codex: not sleepy");
        return (
            dragon.hunger() + 10,
            dragon.uncleanliness() + 10,
            dragon.boredom(),
            0,
            dragon.loyalty(caller) + 10,
            mana - 1000
        );
    }

    function attackEffects(
        Dragon attackerDragon,
        Dragon /*targetDragon*/,
        address caller,
        uint mana
    ) public view returns (uint, uint, uint, uint, uint, uint) {
        return (
            attackerDragon.hunger() + 20,
            attackerDragon.uncleanliness() + 20,
            attackerDragon.boredom() + 20,
            attackerDragon.sleepiness() + 20,
            attackerDragon.loyalty(caller) - 100,
            mana - 10000
        );
    }

    function breedProposalEffects(
        Dragon proposerDragon,
        Dragon targetDragon,
        address caller,
        uint mana
    ) public view returns (uint, uint, uint, uint, uint, uint) {
        require(proposerDragon.hunger() < 50, "Codex: too hungry");
        require(proposerDragon.uncleanliness() < 50, "Codex: too dirty");
        require(proposerDragon.boredom() < 50, "Codex: too bored");
        require(proposerDragon.sleepiness() < 50, "Codex: too sleepy");
        require(proposerDragon.lastBreedingTime() + 7 days < block.timestamp, "Codex: too soon for me");
        require(targetDragon.lastBreedingTime() + 7 days < block.timestamp, "Codex: too soon for them");
        return (
            proposerDragon.hunger(),
            proposerDragon.uncleanliness(),
            proposerDragon.boredom(),
            proposerDragon.sleepiness(),
            proposerDragon.loyalty(caller) - (10 + (10 * proposerDragon.childrenCount())),
            mana - 10000
        );
    }

    function breedAcceptanceEffects(
        Dragon accepterDragon,
        Dragon proposerDragon,
        address caller,
        uint mana
    ) public view returns (uint, uint, uint, uint, uint, uint) {
        require(accepterDragon.hunger() < 50, "Codex: too hungry");
        require(accepterDragon.uncleanliness() < 50, "Codex: too dirty");
        require(accepterDragon.boredom() < 50, "Codex: too bored");
        require(accepterDragon.sleepiness() < 50, "Codex: too sleepy");
        require(accepterDragon.lastBreedingTime() + 7 days < block.timestamp, "Codex: too soon for me");
        require(proposerDragon.lastBreedingTime() + 7 days < block.timestamp, "Codex: too soon for them");
        return (
            accepterDragon.hunger(),
            accepterDragon.uncleanliness(),
            accepterDragon.boredom(),
            accepterDragon.sleepiness(),
            accepterDragon.loyalty(caller) - (10 + (10 * accepterDragon.childrenCount())),
            mana - 10000
        );
    }
}