const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploy usando conta:", deployer.address);

  const ethUsdSepolia = "0x694AA1769357215DE4FAC081bf1f309aDC325306";

  const Token = await ethers.getContractFactory("ProtocoloToken");
  const token = await Token.deploy(deployer.address);
  await token.waitForDeployment();
  console.log("ProtocoloToken:", await token.getAddress());

  const NFT = await ethers.getContractFactory("ProtocoloNFT");
  const nft = await NFT.deploy(deployer.address);
  await nft.waitForDeployment();
  console.log("ProtocoloNFT:", await nft.getAddress());

  const Staking = await ethers.getContractFactory("StakingRewards");
  const staking = await Staking.deploy(
    deployer.address,
    await token.getAddress(),
    await token.getAddress(),
    ethUsdSepolia
  );
  await staking.waitForDeployment();
  console.log("StakingRewards:", await staking.getAddress());

  const minimumTokensToPropose = ethers.parseEther("100");
  const DAO = await ethers.getContractFactory("SimpleDAO");
  const dao = await DAO.deploy(deployer.address, await token.getAddress(), minimumTokensToPropose);
  await dao.waitForDeployment();
  console.log("SimpleDAO:", await dao.getAddress());

  const rewardPool = ethers.parseEther("10000");
  await (await token.transfer(await staking.getAddress(), rewardPool)).wait();
  console.log("Pool inicial de recompensas enviado ao staking:", ethers.formatEther(rewardPool), "PWT");

  console.log("\nEnderecos para README:");
  console.log({
    token: await token.getAddress(),
    nft: await nft.getAddress(),
    staking: await staking.getAddress(),
    dao: await dao.getAddress(),
    oracle: ethUsdSepolia
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
