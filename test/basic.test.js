const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Protocolo Web3 MVP", function () {
  async function deployFixture() {
    const [owner, user] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("ProtocoloToken");
    const token = await Token.deploy(owner.address);

    const NFT = await ethers.getContractFactory("ProtocoloNFT");
    const nft = await NFT.deploy(owner.address);

    const MockOracle = await ethers.getContractFactory("MockPriceFeed");
    const oracle = await MockOracle.deploy(3000n * 100000000n);

    const Staking = await ethers.getContractFactory("StakingRewards");
    const staking = await Staking.deploy(
      owner.address,
      await token.getAddress(),
      await token.getAddress(),
      await oracle.getAddress()
    );

    const DAO = await ethers.getContractFactory("SimpleDAO");
    const dao = await DAO.deploy(owner.address, await token.getAddress(), ethers.parseEther("100"));

    await token.transfer(user.address, ethers.parseEther("1000"));
    await token.transfer(await staking.getAddress(), ethers.parseEther("10000"));

    return { user, token, nft, staking, dao };
  }

  it("permite mint de NFT, stake e criacao de proposta", async function () {
    const { user, token, nft, staking, dao } = await deployFixture();

    await nft.mint(user.address, "ipfs://metadata");
    expect(await nft.ownerOf(1)).to.equal(user.address);

    await token.connect(user).approve(await staking.getAddress(), ethers.parseEther("50"));
    await staking.connect(user).stake(ethers.parseEther("50"));
    expect(await staking.stakedBalance(user.address)).to.equal(ethers.parseEther("50"));

    await dao.connect(user).createProposal("Teste de governanca", 3600);
    await dao.connect(user).vote(1, true);
    const proposal = await dao.proposals(1);
    expect(proposal.votesFor).to.equal(ethers.parseEther("1000"));
  });
});
