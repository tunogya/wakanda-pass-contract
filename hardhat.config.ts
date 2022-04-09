import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@openzeppelin/hardhat-upgrades";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import * as process from "process";

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const mnemonic = process.env.HDWALLET_MNEMONIC;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      accounts: {
        mnemonic: mnemonic,
      },
    },
    rinkeby: {
      url: process.env.RINKEBY_URL || "",
      accounts: {
        mnemonic: mnemonic,
      },
    },
    arbitrum_rinkeby: {
      url: process.env.ARBITRUM_RINKEBY_URL || "",
      accounts: {
        mnemonic: mnemonic,
      },
    },
    bscTestnet: {
      url: process.env.BSCTESTNET_URL || "",
      accounts: {
        mnemonic: mnemonic,
      },
    },
    polygonMumbai: {
      url: process.env.MUMBAI_URL || "",
      accounts: {
        mnemonic: mnemonic,
      },
    },
    goerli: {
      url: process.env.GOERLI_URL || "",
      accounts: {
        mnemonic: mnemonic,
      },
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: {
      rinkeby: process.env.ETHERSCAN_API_KEY,
      goerli: process.env.ETHERSCAN_API_KEY,
      arbitrumOne: process.env.ARBISCAN_API_KEY,
      arbitrumTestnet: process.env.ARBISCAN_API_KEY,
      bsc: process.env.BSCSCAN_API_KEY,
      bscTestnet: process.env.BSCSCAN_API_KEY,
      polygonMumbai: process.env.POLYGONSCAN_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY,
    },
  },
};

export default config;
