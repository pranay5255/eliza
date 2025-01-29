import { Platform } from "eliza";
import {
    ITrustScore,
    ITrustScoreCalculator,
    ITrustScoreRepository,
} from "./interfaces/ITrustScore";

export class TrustEngine
    implements ITrustScoreCalculator, ITrustScoreRepository
{
    private scores: Map<string, ITrustScore> = new Map();
    private leaderboard: ITrustScore[] = [];

    constructor(private readonly platform: Platform) {}

    public async calculateScore(
        metrics: ITrustScore["metrics"]
    ): Promise<number> {
        const factors = {
            successRate: metrics.successfulTrades / metrics.totalTrades,
            profitFactor:
                metrics.profitLoss > 0 ? Math.log10(metrics.profitLoss + 1) : 0,
            riskAdjustment: 1 - metrics.riskScore / 100,
        };

        const weightedScore =
            factors.successRate * 0.4 +
            factors.profitFactor * 0.4 +
            factors.riskAdjustment * 0.2;

        return this.normalizeScore(weightedScore);
    }

    public normalizeScore(score: number): number {
        return Math.min(Math.max(score, 0), 1);
    }

    public validateScore(score: number): boolean {
        return score >= 0 && score <= 1;
    }

    public async getScore(agentId: string): Promise<ITrustScore> {
        const score = this.scores.get(agentId);
        if (!score) {
            throw new Error(`No score found for agent ${agentId}`);
        }
        return score;
    }

    public async updateScore(score: ITrustScore): Promise<void> {
        this.scores.set(score.agentId, score);
        this.updateLeaderboard();
    }

    public async getTopScores(limit: number): Promise<ITrustScore[]> {
        return [...this.leaderboard]
            .sort((a, b) => b.score - a.score)
            .slice(0, limit);
    }

    private updateLeaderboard(): void {
        this.leaderboard = Array.from(this.scores.values());
    }
}
