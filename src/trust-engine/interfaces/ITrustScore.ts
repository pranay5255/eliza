export interface ITrustScore {
  agentId: string;
  score: number;
  timestamp: number;
  metrics: {
    successfulTrades: number;
    totalTrades: number;
    profitLoss: number;
    riskScore: number;
  };
}

export interface ITrustScoreCalculator {
  calculateScore(metrics: ITrustScore['metrics']): Promise<number>;
  normalizeScore(score: number): number;
  validateScore(score: number): boolean;
}

export interface ITrustScoreRepository {
  getScore(agentId: string): Promise<ITrustScore>;
  updateScore(score: ITrustScore): Promise<void>;
  getTopScores(limit: number): Promise<ITrustScore[]>;
}