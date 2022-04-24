import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, ContractFactory, utils } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

const { getSigners } = ethers;
const { parseEther: toWei } = utils;

describe("TestMintableERC20", function () {
  let token: Contract;
  let wallet1: SignerWithAddress;
  let wallet2: SignerWithAddress;

  const tokenName = "Wakanda Carbon Credit";
  const tokenSymbol = "WCO2";

  beforeEach(async () => {
    [wallet1, wallet2] = await getSigners();
    const tokenFactory: ContractFactory = await ethers.getContractFactory(
      "MintableERC20"
    );
    token = await tokenFactory.deploy(tokenName, tokenSymbol, wallet1);
  });

  describe("constructor()", () => {
    it("should initialize token", async () => {
      expect(await token.name()).to.equal(tokenName);
      expect(await token.symbol()).to.equal(tokenSymbol);
      expect(await token.decimals()).to.equal(18);
    });
  });
  describe("decimals()", () => {
    it("should return default decimals", async () => {
      expect(await token.decimals()).to.equal(18);
    });
  });
  describe("balanceOf()", () => {
    it("should return user balance", async () => {
      const mintBalance = toWei("1000");

      await token.mint(wallet1.address, mintBalance);

      expect(await token.balanceOf(wallet1.address)).to.equal(mintBalance);
    });
  });
  describe("totalSupply()", () => {
    it("should return total supply of tickets", async () => {
      const mintBalance = toWei("1000");

      await token.mint(wallet1.address, mintBalance);
      await token.mint(wallet2.address, mintBalance);

      expect(await token.totalSupply()).to.equal(mintBalance.mul(2));
    });
  });
});
