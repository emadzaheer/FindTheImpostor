// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FindTheImpostor {

    address Admin;
    uint256 Id;
    uint256 public totalPlayers;
    uint256 public totalActivePlayers;
    address[] public Winner;
    bool RegistrationOpen = true;

    struct S_Player {
        bool isAlive;
        bool isImpostor;
    }

    uint256[] impostors;
    mapping (address => uint256) public m_PlayerId;
    mapping (uint256 => S_Player) public m_Players;

    // Constructor
    constructor() {
        Admin = msg.sender;
    }

    // Register new players
    function Register() public {
        require(RegistrationOpen, "No more registrations");
        require(m_PlayerId[msg.sender] == 0, "Player already registered");
        ++Id;
        ++totalPlayers;

        m_PlayerId[msg.sender] = Id;
        m_Players[Id].isAlive = true;
        // Event can be added here if needed
    }

    // Assign 3 random alive players as impostors
    function assignImpostors() public {
        
        require(msg.sender == Admin, "Only the admin can assign impostors.");
        require(totalPlayers >= 3, "At least 3 players are required to assign impostors.");
        RegistrationOpen = false;

        while (impostors.length < 3) {
            uint randomId = getRandomNumber(totalPlayers) + 1; // Generate a random player ID
            if (m_Players[randomId].isAlive && !m_Players[randomId].isImpostor) {
                m_Players[randomId].isImpostor = true;
                impostors.push(randomId);
            }
        }
        totalActivePlayers = totalPlayers;
    }

    // Generate a pseudo-random number within a range [0, max)
    function getRandomNumber(uint max) public view returns (uint) {
        require(max > 0, "Max must be greater than 0");
        uint random = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
        return random % max;
    }

    // Kill function accessible only by impostors
    function kill() public {
        uint256 callerId = m_PlayerId[msg.sender];
        require(m_Players[callerId].isAlive, "Player should be alive.");
        require(m_Players[callerId].isImpostor, "Only impostors can use this function.");
        require(totalPlayers > 3, "Game cannot continue if too few players are left.");

        // Find a random non-impostor player to kill
        uint randomId;
         do {
            randomId = getRandomNumber(totalPlayers) + 1; // Generate a random player ID
        } while (!m_Players[randomId].isAlive || m_Players[randomId].isImpostor);


        // Kill the player
        m_Players[randomId].isAlive = false;
        totalActivePlayers--; // Decrease total alive players

        // Event can be added here if needed
    }

    // Check if a player is an impostor
    function frameTheImpostor() public view returns (bool) {
        uint256 callerId = m_PlayerId[msg.sender];
        require(m_Players[callerId].isAlive , "Player should be alive.");

        return m_Players[callerId].isImpostor;
    }

    // Check a player's status
    function checkMyStatus() public view returns (string memory) {
        require(m_PlayerId[msg.sender] != 0, "Player is not registered.");
        uint256 id = m_PlayerId[msg.sender];
        require(m_Players[id].isAlive, "Player is not alive.");

        if (m_Players[id].isImpostor) {
            return "Impostor";
        } else {
            return "Player";
        }
    }

    function retrieveImpostors() public view returns (uint256[] memory ){
        require(msg.sender == Admin, "only the admin can call");
        return impostors;
    }
}
