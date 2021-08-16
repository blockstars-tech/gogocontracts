const assert = require("chai").assert;
const truffleAssert = require("truffle-assertions");

const GoldToken = artifacts.require("GoldToken");
const BridgePublic = artifacts.require("BridgePublic");

contract("GoldToken", (accounts) => {
  // account addresses
  const [contractOwnerAddr, gogoServiceAddrs, address1, address2] = accounts;
  // bridge instance
  let bridgePublicInstance;
  // goldTokenInstance
  let goldTokenInstance;

  beforeEach("Deploying GoldToken and BridgePublic contracts", async () => {
    goldTokenInstance = await GoldToken.new("GoldToken", "GT", {
      from: contractOwnerAddr,
    });
    bridgePublicInstance = await BridgePublic.new(
      goldTokenInstance.address,
      gogoServiceAddrs,
      { from: contractOwnerAddr }
    );
  });

  it("bridgeAddress variable must be 0 address before calling setBridgeAddress() function", async () => {
    let bridgeAddress = await goldTokenInstance.bridgeAddress();
    assert.equal(parseInt(bridgeAddress), 0);
  });

  it("Should have 0 decimals", async () => {
    const decimals = await goldTokenInstance.decimals();
    assert.equal(decimals, 0);
  });

  describe("testing setBridgeAddress function", () => {
    it("Only owner can call this function", async () => {
      await truffleAssert.reverts(
        goldTokenInstance.setBridgeAddress(bridgePublicInstance.address, {
          from: address1,
        }),
        "Function can call only contract owner"
      );
    });

    it("Bridge Address changed", async () => {
      await goldTokenInstance.setBridgeAddress(bridgePublicInstance.address, {
        from: contractOwnerAddr,
      });
      const bridgeAddress = await goldTokenInstance.bridgeAddress();
      assert.equal(bridgeAddress, bridgePublicInstance.address);
    });

    it("Can call setBridgeAddress only once", async () => {
      await goldTokenInstance.setBridgeAddress(bridgePublicInstance.address, {
        from: contractOwnerAddr,
      });
      await truffleAssert.reverts(
        goldTokenInstance.setBridgeAddress(bridgePublicInstance.address, {
          from: contractOwnerAddr,
        }),
        "Bridge address is already setted"
      );
    });
  });

  it("mint function can call only bridge", async () => {
    await truffleAssert.reverts(
      goldTokenInstance.mint(address2, 10000, { from: address1 }),
      "Function can call only bridge"
    );
  });

  it("burn function can call only bridge", async () => {
    await truffleAssert.reverts(
      goldTokenInstance.burn(address2, 10000, { from: address1 }),
      "Function can call only bridge"
    );
  });
});
