const BridgePublic = artifacts.require("BridgePublic");
const GoldToken = artifacts.require("GoldToken");

module.exports = (deployer) => {
  deployer.deploy(BridgePublic, GoldToken.address);
};
