const assert = require("chai").assert;
const truffleAssert = require("truffle-assertions");

const keys = require("./keys.json");

const GoldToken = artifacts.require("GoldToken");
const BridgePublic = artifacts.require("BridgePublic");

contract("BridgePublic", async (accounts) => {
  // account addresses
  const [contractOwnerAddr, gogoServiceAddrs, address1, address2] = accounts;
  // bridge instance
  let bridgePublicInstance;
  // goldTokenInstance
  let gogoPublicInstance;
  // get signature function
  const getSignature = async (userAddress, amount, nonce, direction, signingAddress) => {
    const data = await bridgePublicInstance.formSigningData(userAddress, amount, nonce, direction);
    const privateKey = keys.private_keys[signingAddress.toLowerCase()];
    const { signature } = await web3.eth.accounts.sign(data, privateKey);
    return signature;
  };

  beforeEach("Deploy GoldToken and BridgePublic Contracts", async () => {
    gogoPublicInstance = await GoldToken.new("GoldToken", "GT", { from: contractOwnerAddr });
    bridgePublicInstance = await BridgePublic.new(
      gogoPublicInstance.address,
      gogoServiceAddrs,
      { from: contractOwnerAddr }
    );
    await gogoPublicInstance.setBridgeAddress(bridgePublicInstance.address, { from: contractOwnerAddr });
  });

  describe("testing receiveFromPrivateBridge function", () => {
    it("direction must be false", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, true, gogoServiceAddrs];
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePublicInstance.receiveFromPrivateBridge(userAddress, amount, nonce, direction, signature),
        "direction must be false"
      );
    });

    it("signer must be gogoService", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, false, address2];
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePublicInstance.receiveFromPrivateBridge(userAddress, amount, nonce, direction, signature),
        "recovered address is not gogoService address"
      );
    });

    it("cannot receive from private bridge if nonce already used", async () => {
      // initialize
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, false, gogoServiceAddrs];
      // get signature
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      // calling function
      await bridgePublicInstance.receiveFromPrivateBridge(userAddress, amount, nonce, direction, signature);
      await truffleAssert.reverts(
        bridgePublicInstance.receiveFromPrivateBridge(userAddress, amount, nonce, direction, signature),
        "nonce in toPublicNonces already exist"
      );
    });

    it("transaction successfully completed", async () => {
      // initialize
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, false, gogoServiceAddrs];
      // get signature
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      // get address1 balance before
      const balanceBefore = await gogoPublicInstance.balanceOf(address1);
      // calling function
      const result = await bridgePublicInstance.receiveFromPrivateBridge(userAddress, amount, nonce, direction, signature);
      // get address1 balance after 
      const balanceAfter = await gogoPublicInstance.balanceOf(address1);
      // get toPublicNonces nonce value
      const isInPublicNonce = await bridgePublicInstance.toPublicNonces(nonce);
      // assertions
      truffleAssert.eventEmitted(result, "MintedToGoldToken", (event) => {
        return event.userAddress == userAddress && event.amount == amount;
      });
      assert.equal(balanceAfter - balanceBefore, amount, "balance does not changed");
      assert.isTrue(isInPublicNonce, "toPublicNonces[nonce] should be true");
    });
  });

  describe("testing sendToPrivateBridge function", () => {
    it("direction must be true", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, false, gogoServiceAddrs];
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePublicInstance.sendToPrivateBridge(userAddress, amount, nonce, direction, signature),
        "direction must be true"
      );
    });

    it("signer must be gogoService", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, true, address2];
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePublicInstance.sendToPrivateBridge(userAddress, amount, nonce, direction, signature),
        "recovered address is not gogoService address"
      );
    });

    it("amount must be allowed to contract for burning", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, true, gogoServiceAddrs];
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePublicInstance.sendToPrivateBridge(userAddress, amount, nonce, direction, signature),
        "ERC20: burn amount_ exceeds allowance"
      );
    });

    describe("testing cases when required minting to address", () => {
      beforeEach("mint to address1 account", async () => {
        // initialize
        const [userAddress, amount, nonce, direction, signingAddress] 
          = [address1, 1000, 10, false, gogoServiceAddrs];
        // get signature
        const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
        // calling function
        await bridgePublicInstance.receiveFromPrivateBridge(userAddress, amount, nonce, direction, signature);
      });

      it("cannot send to private bridge if nonce already used", async () => {
        // initialize
        const [userAddress, amount, nonce, direction, signingAddress] 
          = [address1, 1000, 10, true, gogoServiceAddrs];
        // get signature
        const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
        // approve 
        await gogoPublicInstance.approve(bridgePublicInstance.address, amount, { from: address1 });
        // calling function
        await bridgePublicInstance.sendToPrivateBridge(userAddress, amount, nonce, direction, signature);
        await truffleAssert.reverts(
          bridgePublicInstance.sendToPrivateBridge(userAddress, amount, nonce, direction, signature),
          "nonce in toPrivateNonces already exist"
        );
      });

      it("transaction successfully completed", async () => {
        // initialize
        const [userAddress, amount, nonce, direction, signingAddress] 
          = [address1, 1000, 10, true, gogoServiceAddrs];
        // get signature
        const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
        // get contract balance before
        const balanceBefore = await gogoPublicInstance.balanceOf(address1);
        // approve 
        await gogoPublicInstance.approve(bridgePublicInstance.address, amount, { from: address1 });
        // calling function
        const result = await bridgePublicInstance.sendToPrivateBridge(userAddress, amount, nonce, direction, signature);
        // get contract balance after 
        const balanceAfter = await gogoPublicInstance.balanceOf(address1);
        // get toPublicNonces nonce value
        const isInPrivateNonce = await bridgePublicInstance.toPrivateNonces(nonce);
        // assertions
        truffleAssert.eventEmitted(result, "BurnedFromGoldToken", (event) => {
          return event.userAddress == userAddress && event.amount == amount;
        })
        assert.equal(balanceBefore - balanceAfter, amount, "balance does not changed");
        assert.isTrue(isInPrivateNonce, "toPrivateNonces[nonce] should be true");
      });
    })

  });
});
