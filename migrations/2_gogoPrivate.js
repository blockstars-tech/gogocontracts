const GogoPrivate = artifacts.require("GogoPrivate");

module.exports = (deployer) => {
  deployer.deploy(GogoPrivate, "GogoPrivate", "GP");
};
