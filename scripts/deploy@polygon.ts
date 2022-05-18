import { ethers, network } from "hardhat";
import chalk from "chalk";
import { ContractFactory } from "ethers";

const dim = (text: string) => {
  console.log(chalk.dim(text));
};

const green = (text: string) => {
  console.log(chalk.green(text));
};

/**
 * Polygon Child Manager contract addresses:
 *    "Mumbai": "0xb5505a6d998549090530911180f38aC5130101c6"
 *    "Mainnet": "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa"
 *
 * ROLE:
 *    "DEPOSITOR_ROLE": "0x8f4f2da22e8ac8f11e15f9fc141cddbb5deea8800186560abb6e68c5496619a9"
 *    "MINTER_ROLE": "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"
 *
 * MintableAssetProxy
 *    Goerli Testnet:
 *        "MintableERC20PredicateProxy": "0x37c3bfC05d5ebF9EBb3FF80ce0bd0133Bf221BC8",
 *        "MintableERC721PredicateProxy": "0x56E14C4C1748a818a5564D33cF774c59EB3eDF59",
 *        "MintableERC1155PredicateProxy": "0x72d6066F486bd0052eefB9114B66ae40e0A6031a",
 *    Ethereum Mainnet:
 *        "MintableERC20PredicateProxy": "0x9923263fA127b3d1484cFD649df8f1831c2A74e4",
 *        "MintableERC721PredicateProxy": "0x932532aA4c0174b8453839A6E44eE09Cc615F2b7",
 *        "MintableERC1155PredicateProxy": "0x2d641867411650cd05dB93B59964536b1ED5b1B7",
 */

async function main() {
  const signers = await ethers.getSigners();
  dim(`signer: ${signers[0].address}`);
  const MintableERC20 = await ethers.getContractFactory("MintableERC20");
  // const WCO2 = await MintableERC20.deploy(
  //   "Wakanda Carbon Credit",
  //   "WCO2",
  //   "0xB964b01281DF695Db1679bE4365Bc6afB7361CbF"
  // );
  // await WCO2.deployed();
  const WCO2 = MintableERC20.attach(
    "0x7Fd8e00bba10685794326917e3f1c0B4db2D93F7"
  );
  green(`Wakanda Carbon MintableERC20 deployed to: ${WCO2.address}`);
  dim(
    `hh verify --network ${network.name} ${WCO2.address} "Wakanda Carbon Credit" WCO2 0xB964b01281DF695Db1679bE4365Bc6afB7361CbF`
  );
  const Rewards: ContractFactory = await ethers.getContractFactory("Rewards");
  const rewards = await Rewards.deploy(WCO2.address);
  await rewards.deployed();
  green(`Rewards deployed to ${rewards.address}`);
  dim(`hh verify --network ${network.name} ${rewards.address} ${WCO2.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
