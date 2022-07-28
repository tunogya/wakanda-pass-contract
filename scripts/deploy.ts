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
  const WakandaPass: ContractFactory = await ethers.getContractFactory(
    "WakandaPass"
  );
  const wakandapsss = await WakandaPass.deploy("WakandaPass", "WP");
  await wakandapsss.deployed();
  // const wakandapsss = await WakandaPass.attach(
  //   ""
  // );
  green(`WakandaPass deployed to: ${wakandapsss.address}`);
  dim(
    `hh verify --network ${network.name} ${wakandapsss.address} WakandaPass WP`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
