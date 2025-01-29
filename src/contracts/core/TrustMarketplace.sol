// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/ITrustMarketplace.sol";

contract TrustMarketplace is ITrustMarketplace, Ownable, ReentrancyGuard {
    mapping(address => AgentScore) public agentScores;
    address[] public rankedAgents;
    IERC20 public governanceToken;

    constructor(address _governanceToken) {
        governanceToken = IERC20(_governanceToken);
    }

    function registerAgent() external override {
        require(agentScores[msg.sender].timestamp == 0, "Agent already registered");
        require(governanceToken.balanceOf(msg.sender) > 0, "Must hold governance token");

        agentScores[msg.sender] = AgentScore({
            score: 0,
            timestamp: block.timestamp,
            totalTrades: 0,
            successfulTrades: 0,
            profitLoss: 0,
            riskScore: 50
        });

        rankedAgents.push(msg.sender);
        emit AgentRegistered(msg.sender, block.timestamp);
    }

    function updateScore(
        address agent,
        uint256 newTotalTrades,
        uint256 newSuccessfulTrades,
        int256 newProfitLoss,
        uint256 newRiskScore
    ) external override onlyOwner {
        require(agentScores[agent].timestamp != 0, "Agent not registered");

        AgentScore storage score = agentScores[agent];
        score.totalTrades = newTotalTrades;
        score.successfulTrades = newSuccessfulTrades;
        score.profitLoss = newProfitLoss;
        score.riskScore = newRiskScore;
        score.timestamp = block.timestamp;

        uint256 newScore = calculateNormalizedScore(
            newSuccessfulTrades,
            newTotalTrades,
            newProfitLoss,
            newRiskScore
        );
        score.score = newScore;

        emit ScoreUpdated(agent, newScore, block.timestamp);
        updateRankings();
    }

    function calculateNormalizedScore(
        uint256 successfulTrades,
        uint256 totalTrades,
        int256 profitLoss,
        uint256 riskScore
    ) public pure override returns (uint256) {
        if (totalTrades == 0) return 0;

        uint256 successRate = (successfulTrades * 100) / totalTrades;
        uint256 profitComponent = profitLoss > 0 ? uint256(profitLoss) : 0;
        uint256 riskAdjustment = 100 - riskScore;

        return (
            (successRate * 40 +
            (profitComponent * 40) / 100 +
            riskAdjustment * 20)
        ) / 100;
    }

    function getTopAgents(uint256 limit) external view override returns (address[] memory, uint256[] memory) {
        uint256 resultSize = limit > rankedAgents.length ? rankedAgents.length : limit;
        address[] memory agents = new address[](resultSize);
        uint256[] memory scores = new uint256[](resultSize);

        for (uint256 i = 0; i < resultSize; i++) {
            agents[i] = rankedAgents[i];
            scores[i] = agentScores[rankedAgents[i]].score;
        }

        return (agents, scores);
    }

    function updateRankings() internal {
        uint256 n = rankedAgents.length;
        for (uint256 i = 0; i < n - 1; i++) {
            for (uint256 j = 0; j < n - i - 1; j++) {
                if (agentScores[rankedAgents[j]].score < agentScores[rankedAgents[j + 1]].score) {
                    address temp = rankedAgents[j];
                    rankedAgents[j] = rankedAgents[j + 1];
                    rankedAgents[j + 1] = temp;
                }
            }
        }
    }
}