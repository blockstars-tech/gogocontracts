import "@nomiclabs/hardhat-truffle5";
import "@typechain/hardhat";
import { HardhatNetworkForkingUserConfig, HardhatUserConfig } from "hardhat/types";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  typechain: {
    target: "truffle-v5",
  },
  networks: {
    test: {
      url: "http://127.0.0.1:8545"
    }
  },
};

export default config;