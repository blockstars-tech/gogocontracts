const assert = require("chai").assert;
const truffleAssert = require("truffle-assertions");

const GoldToken = artifacts.require("GoldToken");
const BridgePublic = artifacts.require("BridgePublic");

contract("GoldToken",async (accounts) => {
  // account addresses
  const [contractOwnerAddr, gogoServiceAddrs, address1, address2, feeCollector] = accounts;
  // bridge instance
  let bridgePublicInstance;
  // goldTokenInstance
  let goldTokenInstance;

  beforeEach("Deploying GoldToken and BridgePublic contracts", async () => {
    goldTokenInstance = await GoldToken.new({
      from: contractOwnerAddr,
    });
    bridgePublicInstance = await BridgePublic.new(
      goldTokenInstance.address,
      { from: contractOwnerAddr }
    );
  });

  it("bridgeAddress variable must be 0 address before calling setBridgeAddress() function", async () => {
    let bridgeAddress = await goldTokenInstance.bridgeAddress();
    assert.equal(parseInt(bridgeAddress), 0);
  });

  it("Should have 18 decimals", async () => {
    const decimals = await goldTokenInstance.decimals();
    assert.equal(decimals, 18);
  });

  describe("testing setBridgeAddress function", () => {
    it("Only ADMIN can call this function", async () => {
      await truffleAssert.reverts(
        goldTokenInstance.setBridgeAddress(bridgePublicInstance.address, {
          from: address1,
        }),
        "Function caller is not an ADMIN"
      );
    });

    it("Bridge Address changed", async () => {
      await goldTokenInstance.setBridgeAddress(bridgePublicInstance.address, {
        from: contractOwnerAddr,
      });
      const bridgeAddress = await goldTokenInstance.bridgeAddress();
      assert.equal(bridgeAddress, bridgePublicInstance.address);
    });

    it("Cannot set same bridge address", async () => {
      await goldTokenInstance.setBridgeAddress(bridgePublicInstance.address, {
        from: contractOwnerAddr,
      });
      await truffleAssert.reverts(
        goldTokenInstance.setBridgeAddress(bridgePublicInstance.address, { from: contractOwnerAddr }),
        "Given address is current bridge address"
      ); 
    });
  });

  it("mint function can call only bridge", async () => {
    await truffleAssert.reverts(
      goldTokenInstance.mint(address2, 10000, { from: address1 }),
      "This function can call only Bridge"
    );
  });

  it("burn function can call only bridge", async () => {
    await truffleAssert.reverts(
      goldTokenInstance.burn(address2, 10000, { from: address1 }),
      "This function can call only Bridge"
    );
  });

  it("should collect transaction fee", async() => {
    const ROLE_2 = 2

    await goldTokenInstance.setRoleTxnFee(ROLE_2, 10, {from: contractOwnerAddr});
    await goldTokenInstance.grantRole(ROLE_2, address1, {from: contractOwnerAddr});
    await goldTokenInstance.setTransactionFeeCollector(feeCollector, {from: contractOwnerAddr});

    const address1BalanceBefore = await goldTokenInstance.balanceOf(address1);
    const transferAmount = 10000;
    const ROLE2txhFee = await goldTokenInstance.roleTxnFee(ROLE_2);
    await goldTokenInstance.transfer(address1, transferAmount, {from: contractOwnerAddr});
    const address1BalanceAfter = await goldTokenInstance.balanceOf(address1);
    assert.isTrue(address1BalanceBefore.addn(transferAmount).eq(address1BalanceAfter), "Balances arnt equal after transfer");

    const address2BalanceBefore = await goldTokenInstance.balanceOf(address2);
    const feeCollectorBalanceBefore = await goldTokenInstance.balanceOf(feeCollector);
    await goldTokenInstance.transfer(address2, transferAmount, {from: address1});
    const address2BalanceAfter = await goldTokenInstance.balanceOf(address2);
    const feeCollectorBalanceAfter = await goldTokenInstance.balanceOf(feeCollector);

    assert.isTrue(address2BalanceBefore.addn(transferAmount - (transferAmount * ROLE2txhFee / 10000)).eq(address2BalanceAfter), "Balances aren't equal after transfer");
    assert.isTrue(feeCollectorBalanceBefore.addn(transferAmount * ROLE2txhFee / 10000).eq(feeCollectorBalanceAfter), "Fee Collector balances aren't equal after transfer");
  
  })
});
