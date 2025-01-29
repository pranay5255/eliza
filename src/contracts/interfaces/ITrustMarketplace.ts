export interface ITrustMarketplace {
  registerAgent(): Promise<void>;
  updateScore(
    agent: string,
    newTotalTrades: number,
    newSuccessfulTrades: number,
    newProfitLoss: number,
    newRiskScore: number
  ): Promise<void>;
  getTopAgents(limit: number): Promise<[string[], number[]]>;
}