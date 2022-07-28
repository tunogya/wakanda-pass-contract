import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("TestWakandaPass", function () {
  let wakandapass: Contract;
  let Alice: SignerWithAddress;

  const name = "WakandaPass";
  const symbol = "WP";

  beforeEach(async () => {
    [Alice] = await ethers.getSigners();
    const tokenFactory: ContractFactory = await ethers.getContractFactory(
      "WakandaPass"
    );
    wakandapass = await tokenFactory.deploy(name, symbol);
  });

  describe("constructor()", () => {
    it("should init name and symbol", async () => {
      await expect(await wakandapass.name()).to.equal(name);
      await expect(await wakandapass.symbol()).to.equal(symbol);
    });
  });

  describe("totalSupply()", () => {
    it("should have 32 genesis wakandapass after init", async () => {
      await expect(await wakandapass.totalSupply()).to.equal(32);
    });
  });

  describe("tokenByIndex()", () => {
    it("token id should be keccak256(id)", async () => {
      await expect(await wakandapass.tokenByIndex(0)).equal(
        "1937035142596246788172577232054709726386880441279550832067530347910661804397"
      );
    });
  });

  describe("tokenByURI()", () => {
    it("tokenURI to tokenId", async () => {
      const [tokenId, exists] = await wakandapass.tokenByURI("0");
      await expect(tokenId.toString()).to.equal(
        "1937035142596246788172577232054709726386880441279550832067530347910661804397"
      );
      await expect(exists).to.equal(true);
    });
  });

  describe("renounce()", () => {
    it("should renounce tokenId 0", async () => {
      const AliceWP = wakandapass.connect(Alice);
      const tokenId0 = await wakandapass.tokenByIndex(0);
      await AliceWP.claim(tokenId0);
      expect(await wakandapass.balanceOf(Alice.address)).to.equal(1);
      await AliceWP.claimByURI("1");
      expect(await wakandapass.balanceOf(Alice.address)).to.equal(2);
    });
  });

  describe("tokenURI()", () => {
    it("should return tokenURI", async () => {
      const tokenId0 = await wakandapass.tokenByIndex(0);
      // const tokenURI = await wakandapass.tokenURI(tokenId0);
      console.log(tokenId0);
    });
  });
});
