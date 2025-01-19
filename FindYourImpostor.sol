// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FindTheImpostor {

    address Admin;
    uint256 Id;
    uint256 public totalPlayers;
    
    address[] public Winners;
    bool RegistrationOpen = true;
    bool GameOn = true;

    struct S_Player {
        bool isAlive;
        bool isImpostor;
    }

    mapping (address => uint256) public m_PlayerId;
    mapping (uint256 => S_Player) public m_Players;

    modifier pausable {
        require(GameOn, "Game Over");
        _;
    }
    
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

    // Assign 1 random alive player as impostor
    function assignImpostor(uint256 I1) public {
        
        require(msg.sender == Admin, "Only the admin can assign impostors.");
        require(totalPlayers >= 1, "At least 3 players are required to assign impostors.");
        RegistrationOpen = false;

        m_Players[I1].isImpostor = true;
        
    }
    

    // Kill function accessible only by impostors
    function kill() public pausable{
        uint256 callerId = m_PlayerId[msg.sender];
        require(m_Players[callerId].isAlive, "Player should be alive.");
        require(m_Players[callerId].isImpostor, "Only impostors can use this function.");
        require(totalPlayers > 1, "Game cannot continue if too few players are left.");

        // Kill the player
        
        bool _isImpostor;
        while (!_isImpostor){
            if(m_Players[totalPlayers].isImpostor) 
                --totalPlayers;
            m_Players[totalPlayers].isAlive = false;   
            --totalPlayers; // Decrease total alive players
            _isImpostor = true;     
        }

        // Event can be added here if needed
    }

    // Check if a player is an impostor
    function catchTheImpostor(uint256 _impostorId) public pausable returns (bool) {
        uint256 callerId = m_PlayerId[msg.sender];
        require(m_Players[callerId].isAlive , "Player should be alive.");

        if(m_Players[_impostorId].isImpostor == true) {
            Winners.push(msg.sender);
            GameOn = false;
        } 
        else revert("Guess Again");
        
        return true;
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

}
