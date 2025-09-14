// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

/**
 * @title A Sample Raffle Contract
 * @author Rishikesh Yadav
 * @notice This contract is for creating a sample contract
 * @dev Implements Chainlink VRFv2.5
 */
contract Raffle {
    /* Errors */
    error Raffle_SendMoreToEnterRaffle();

    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    // User able to buy ticket. that's why this function will be payable.
    function enterRaffle() public payable {
        // require(msg.value >= i_entranceFee, "Not enough ETH sent!");
        // require(msg.value >= i_entranceFee, SendMoreEthToRaffle());
        // Below is the more gas efficient and better way to write condition.
        if (msg.value < i_entranceFee) {
            revert Raffle_SendMoreToEnterRaffle();
        }
    }

    function pickWinner() public {}

    /** Getter Functions */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
