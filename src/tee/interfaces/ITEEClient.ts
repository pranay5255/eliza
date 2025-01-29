export interface IAttestation {
  hash: string;
  timestamp: number;
  signature: string;
  publicKey: string;
}

export interface ITEEConfig {
  agentId: string;
  memoryLimit: number;
  timeLimit: number;
  networkAccess: boolean;
}

export interface ITEEClient {
  requestAttestation(): Promise<IAttestation>;
  verifyAttestation(attestation: IAttestation): Promise<boolean>;
  deploy(config: {
    agent: any;
    config: ITEEConfig;
    attestation: IAttestation;
  }): Promise<string>;
  execute(
    agentId: string,
    functionName: string,
    params: any[]
  ): Promise<any>;
  terminate(agentId: string): Promise<void>;
}