import { ethers } from "hardhat";

async function main() {
  // Deploy TrustToken
  const TrustToken = await ethers.getContractFactory("TrustToken");
  const trustToken = await TrustToken.deploy();
  await trustToken.deployed();
  console.log("TrustToken deployed to:", trustToken.address);

  // Deploy TrustMarketplace
  const TrustMarketplace = await ethers.getContractFactory("TrustMarketplace");
  const trustMarketplace = await TrustMarketplace.deploy(trustToken.address);
  await trustMarketplace.deployed();
  console.log("TrustMarketplace deployed to:", trustMarketplace.address);

  // Deploy AIAgentRegistry
  const AIAgentRegistry = await ethers.getContractFactory("AIAgentRegistry");
  const aiAgentRegistry = await AIAgentRegistry.deploy();
  await aiAgentRegistry.deployed();
  console.log("AIAgentRegistry deployed to:", aiAgentRegistry.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });