const GoldToken = artifacts.require("GoldToken");

module.exports = (deployer) => {
  deployer.deploy(GoldToken);
};
