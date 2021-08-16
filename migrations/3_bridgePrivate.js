const BridgePrivate = artifacts.require("BridgePrivate");
const GogoPrivate = artifacts.require("GogoPrivate");

module.exports = (deployer, network, accounts) => {
  deployer.deploy(BridgePrivate, GogoPrivate.address, accounts[1]);
};
