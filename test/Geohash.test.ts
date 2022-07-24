import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("TestGeohash", function () {
  let geohash: Contract;
  let Alice: SignerWithAddress;
  let Bob: SignerWithAddress;

  const name = "Geohash";
  const symbol = "GEO";

  beforeEach(async () => {
    [Alice, Bob] = await ethers.getSigners();
    const tokenFactory: ContractFactory = await ethers.getContractFactory(
      "Geohash"
    );
    geohash = await tokenFactory.deploy(name, symbol);
  });

  describe("constructor()", () => {
    it("should init name and symbol", async () => {
      await expect(await geohash.name()).to.equal(name);
      await expect(await geohash.symbol()).to.equal(symbol);
    });
  });

  describe("totalSupply()", () => {
    it("should have 32 genesis geohash after init", async () => {
      await expect(await geohash.totalSupply()).to.equal(32);
    });
  });

  describe("tokenByIndex()", () => {
    it("geohash id should be keccak256(id)", async () => {
      await expect(await geohash.tokenByIndex(0)).equal(
        "1937035142596246788172577232054709726386880441279550832067530347910661804397"
      );
    });
  });

  describe("tokenByURI()", () => {
    it("geohash tokenURI to tokenId", async () => {
      const [tokenId, exists] = await geohash.tokenByURI("0");
      await expect(tokenId.toString()).to.equal(
        "1937035142596246788172577232054709726386880441279550832067530347910661804397"
      );
      await expect(exists).to.equal(true);
    });
  });

  describe("renounce()", () => {
    it("should renounce tokenId 0", async () => {
      const AliceGeohash = geohash.connect(Alice);
      const BobGeohash = geohash.connect(Bob);
      const tokenId0 = await geohash.tokenByIndex(0);
      await AliceGeohash.renounce(tokenId0);
      await expect(await geohash.balanceOf(Alice.address)).to.equal(31);
      await expect(await geohash.balanceOf(geohash.address)).to.equal(1);
      await BobGeohash.claim(tokenId0);
      await expect(await geohash.balanceOf(geohash.address)).to.equal(0);
      await expect(await geohash.balanceOf(Bob.address)).to.equal(1);
    });
  });
});
