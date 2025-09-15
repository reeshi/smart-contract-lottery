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

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A Sample Raffle Contract
 * @author Rishikesh Yadav
 * @notice This contract is for creating a sample contract
 * @dev Implements Chainlink VRFv2.5
 */
contract Raffle is VRFConsumerBaseV2Plus {
    /* Errors */
    error Raffle_SendMoreToEnterRaffle();

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_entranceFee;
    // @dev Duration of the lottery in seconds
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint32 private immutable i_callbackGasLimit;
    // we store address of each player. since the winner address will receive money we need to make all the addresses payable in order to send them money.
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    uint256 private s_subscriptionId;

    /*
     * Events
     */
    event RaffleEntered(address indexed player);

    /** Raffle contract is inheriting VRFConsumerBaseV2Plus and VRFConsumerBaseV2Plus take's
     * vrfCoordinator parameter in the constructor that's why we need to call the contructor of that also
     * and syntax of this like below
     */
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gaslane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_keyHash = gaslane;
        s_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    // User able to buy ticket. that's why this function will be payable.
    function enterRaffle() external payable {
        // require(msg.value >= i_entranceFee, "Not enough ETH sent!");
        // require(msg.value >= i_entranceFee, SendMoreEthToRaffle());
        // Below is the more gas efficient and better way to write condition.
        if (msg.value < i_entranceFee) {
            revert Raffle_SendMoreToEnterRaffle();
        }
        s_players.push(payable(msg.sender));

        // Now it's a rule of thumb whenever we update storage variables we need to emit events.
        emit RaffleEntered(msg.sender);
    }

    // 1. Get a random number
    // 2. use random number to pick a player
    // 3. Be automatically called
    function pickWinner() external {
        // check the enough time is passed so that we pick the random number
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });

        // Get the random nunmber
        // 1. requets random number to vrf
        // 2. get the random number
        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal virtual override {}

    /**
     * Getter Functions
     */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
