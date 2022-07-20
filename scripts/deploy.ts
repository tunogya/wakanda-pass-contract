import { ethers, network } from "hardhat";
import chalk from "chalk";
import { ContractFactory } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

const dim = (text: string) => {
  console.log(chalk.dim(text));
};

const green = (text: string) => {
  console.log(chalk.green(text));
};

async function main() {
  const signers: SignerWithAddress[] = await ethers.getSigners();
  dim(`signer: ${signers[0].address}`);
  const GeoHash: ContractFactory = await ethers.getContractFactory("Geohash");
  const geohash = await GeoHash.deploy("WakandaPass", "PASS");
  await geohash.deployed();
  // const geohash = await Geohash.attach(
  //   ""
  // );
  green(`Geohash deployed to: ${geohash.address}`);
  dim(
    `hh verify --network ${network.name} ${geohash.address} WakandaPass PASS`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
