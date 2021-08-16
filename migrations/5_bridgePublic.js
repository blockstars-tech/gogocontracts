const BridgePublic = artifacts.require("BridgePublic");
const GoldToken = artifacts.require("GoldToken");

module.exports = (deployer, network, accounts) => {
  deployer.deploy(BridgePublic, GoldToken.address, accounts[1]);
};
