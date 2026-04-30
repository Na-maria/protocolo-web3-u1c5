const { ethers } = require("hardhat");

const addresses = {
  token: process.env.TOKEN_ADDRESS,
  nft: process.env.NFT_ADDRESS,
  staking: process.env.STAKING_ADDRESS,
  dao: process.env.DAO_ADDRESS
};

async function main() {
  const [user] = await ethers.getSigners();
  console.log("Interagindo com:", user.address);

  for (const [name, value] of Object.entries(addresses)) {
    if (!value || value === "0x...") {
      throw new Error(`Defina ${name.toUpperCase()}_ADDRESS no arquivo .env`);
    }
  }

  const token = await ethers.getContractAt("ProtocoloToken", addresses.token);
  const nft = await ethers.getContractAt("ProtocoloNFT", addresses.nft);
  const staking = await ethers.getContractAt("StakingRewards", addresses.staking);
  const dao = await ethers.getContractAt("SimpleDAO", addresses.dao);

  const nftTx = await nft.mint(user.address, "ipfs://exemplo-metadata-nft");
  await nftTx.wait();
  console.log("Mint de NFT executado");

  const stakeAmount = ethers.parseEther("50");
  await (await token.approve(addresses.staking, stakeAmount)).wait();
  await (await staking.stake(stakeAmount)).wait();
  console.log("Stake executado:", ethers.formatEther(stakeAmount), "PWT");

  const proposalTx = await dao.createProposal(
    "Aumentar recompensas para usuarios ativos do protocolo",
    3600
  );
  await proposalTx.wait();
  console.log("Proposta criada");

  await (await dao.vote(1, true)).wait();
  console.log("Voto registrado na DAO");

  const price = await staking.latestEthUsdPrice();
  console.log("Preco ETH/USD do oraculo:", price.toString());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
