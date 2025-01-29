// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITrustMarketplace {
    struct AgentScore {
        uint256 score;
        uint256 timestamp;
        uint256 totalTrades;
        uint256 successfulTrades;
        int256 profitLoss;
        uint256 riskScore;
    }

    event ScoreUpdated(address indexed agent, uint256 score, uint256 timestamp);
    event AgentRegistered(address indexed agent, uint256 timestamp);

    function registerAgent() external;
    function updateScore(
        address agent,
        uint256 newTotalTrades,
        uint256 newSuccessfulTrades,
        int256 newProfitLoss,
        uint256 newRiskScore
    ) external;
    function getTopAgents(uint256 limit) external view returns (address[] memory, uint256[] memory);
    function calculateNormalizedScore(
        uint256 successfulTrades,
        uint256 totalTrades,
        int256 profitLoss,
        uint256 riskScore
    ) external pure returns (uint256);
}