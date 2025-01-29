// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract AIAgentRegistry is Ownable, Pausable {
    struct Agent {
        string name;
        address owner;
        string teeAttestationHash;
        bool isActive;
        uint256 registrationTime;
    }

    mapping(address => Agent) public agents;
    mapping(address => bool) public verifiedTEEs;

    event AgentRegistered(address indexed agentAddress, string name, address owner);
    event AgentUpdated(address indexed agentAddress, string teeAttestationHash);
    event TEEVerified(address indexed teeAddress);

    modifier onlyAgentOwner(address agentAddress) {
        require(agents[agentAddress].owner == msg.sender, "Not agent owner");
        _;
    }

    function registerAgent(
        address agentAddress,
        string memory name,
        string memory teeAttestationHash
    ) external whenNotPaused {
        require(agents[agentAddress].registrationTime == 0, "Agent already registered");

        agents[agentAddress] = Agent({
            name: name,
            owner: msg.sender,
            teeAttestationHash: teeAttestationHash,
            isActive: true,
            registrationTime: block.timestamp
        });

        emit AgentRegistered(agentAddress, name, msg.sender);
    }

    function updateTEEAttestation(
        address agentAddress,
        string memory newAttestationHash
    ) external onlyAgentOwner(agentAddress) whenNotPaused {
        agents[agentAddress].teeAttestationHash = newAttestationHash;
        emit AgentUpdated(agentAddress, newAttestationHash);
    }

    function verifyTEE(address teeAddress) external onlyOwner {
        verifiedTEEs[teeAddress] = true;
        emit TEEVerified(teeAddress);
    }

    function deactivateAgent(address agentAddress)
        external
        onlyAgentOwner(agentAddress)
    {
        agents[agentAddress].isActive = false;
    }

    function getAgentInfo(address agentAddress)
        external
        view
        returns (Agent memory)
    {
        return agents[agentAddress];
    }
}