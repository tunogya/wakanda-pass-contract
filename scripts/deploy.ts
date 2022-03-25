import { ethers } from "hardhat";
import chalk from "chalk";

const dim = (text: string) => {
  console.log(chalk.dim(text));
};

const green = (text: string) => {
  console.log(chalk.green(text));
};

async function main() {
  const signers = await ethers.getSigners();
  dim(`signer: ${signers[0].address}`);
  const CarbonCredit = await ethers.getContractFactory("CarbonCredit");
  const credit = await CarbonCredit.deploy(
    "Carbon Credit",
    "tCO2e",
    signers[0].address
  );

  await credit.deployed();

  green(`CarbonCredit deployed to: ${credit.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
