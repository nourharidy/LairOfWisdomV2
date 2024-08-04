// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Codex {
    uint constant public baseMaxHealth = 1_000_000;
    uint constant public baseHealthRegen = 10;
    uint constant public baseDamage = 1000;
    uint constant public baseAttackCooldown = 3600; // 1 hour
    uint constant public statsDecay = 100;
    uint constant public healthPenalty = 100;

    // mana costs
    uint constant public proposeBreedingManaCost = 10000;
    uint constant public acceptBreedingManaCost = 10000;

    // loyalty costs
    uint constant public proposeBreedingLoyaltyCost = 100;
    uint constant public acceptBreedingLoyaltyCost = 100;

    function feedEffects(
        uint hunger,
        uint uncleanliness,
        uint boredom,
        uint sleepiness,
        uint loyalty,
        uint mana
    ) public pure returns (uint, uint, uint, uint, uint, uint) {
        require(hunger > 10, "Codex: not hungry");
        return (
            0,
            uncleanliness + 10,
            boredom,
            sleepiness + 10,
            loyalty + 10,
            mana - 100
        );
    }

    function cleanEffects(
        uint hunger,
        uint uncleanliness,
        uint boredom,
        uint sleepiness,
        uint loyalty,
        uint mana
    ) public pure returns (uint, uint, uint, uint, uint, uint) {
        require(uncleanliness > 10, "Codex: not dirty");
        return (
            hunger,
            0,
            boredom,
            sleepiness + 10,
            loyalty + 10,
            mana - 100
        );
    }

    function playEffects(
        uint hunger,
        uint uncleanliness,
        uint boredom,
        uint sleepiness,
        uint loyalty,
        uint mana
    ) public pure returns (uint, uint, uint, uint, uint, uint) {
        require(boredom > 10, "Codex: not bored");
        return (
            hunger + 10,
            uncleanliness,
            0,
            sleepiness + 10,
            loyalty + 10,
            mana - 100
        );
    }

    function sleepEffects(
        uint hunger,
        uint uncleanliness,
        uint boredom,
        uint sleepiness,
        uint loyalty,
        uint mana
    ) public pure returns (uint, uint, uint, uint, uint, uint) {
        require(sleepiness > 10, "Codex: not sleepy");
        return (
            hunger + 10,
            uncleanliness + 10,
            boredom,
            0,
            loyalty + 10,
            mana - 100
        );
    }

    function attackEffects(
        uint hunger,
        uint uncleanliness,
        uint boredom,
        uint sleepiness,
        uint loyalty,
        uint mana
    ) public pure returns (uint, uint, uint, uint, uint, uint) {
        return (
            hunger + 20,
            uncleanliness + 20,
            boredom + 20,
            sleepiness + 20,
            loyalty - 100,
            mana - 100
        );
    }
}