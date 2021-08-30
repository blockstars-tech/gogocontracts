import { assert } from "chai";
import BN from "bn.js";
import { BridgePublicInstance, GoldTokenInstance } from "../typechain";

import { getSignature } from "./utils";

const keys = require("./keys.json");

const GoldToken = artifacts.require("GoldToken");
const BridgePublic = artifacts.require("BridgePublic");

const truffleAssert = require("truffle-assertions");

contract("BridgePublic", async (accounts) => {
  // account addresses
  const [contractOwnerAddr, gogoServiceAddrs, address1, address2] = accounts;
  // bridge instance
  let bridgePublicInstance: BridgePublicInstance;
  // goldTokenInstance
  let gogoPublicInstance: GoldTokenInstance;

  beforeEach("Deploy GoldToken and BridgePublic Contracts", async () => {
    gogoPublicInstance = await GoldToken.new("GoldGo", "GOGO", { from: contractOwnerAddr });
    bridgePublicInstance = await BridgePublic.new(
      gogoPublicInstance.address,
      { from: contractOwnerAddr }
    );
    await bridgePublicInstance.addGogoServiceAddress(gogoServiceAddrs, { from: contractOwnerAddr, });
    await gogoPublicInstance.setBridgeAddress(bridgePublicInstance.address, { from: contractOwnerAddr });
  });

  describe("testing receiveFromPrivateBridge function", () => {
    it("direction must be false", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, new BN(1000), new BN(10), true, gogoServiceAddrs];
      const signature = await getSignature(bridgePublicInstance, userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePublicInstance.receiveFromPrivateBridge(userAddress, amount, nonce, direction, signature),
        "direction must be false"
      );
    });

    it("signer must be gogoService", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, new BN(1000), new BN(10), false, address2];
      const signature = await getSignature(bridgePublicInstance, userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePublicInstance.receiveFromPrivateBridge(userAddress, amount, nonce, direction, signature),
        "Recovered address is not gogoService address"
      );
    });

    it("cannot receive from private bridge if nonce already used", async () => {
      // initialize
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, new BN(1000), new BN(10), false, gogoServiceAddrs];
      // get signature
      const signature = await getSignature(bridgePublicInstance, userAddress, amount, nonce, direction, signingAddress);
      // calling function
      await bridgePublicInstance.receiveFromPrivateBridge(userAddress, amount, nonce, direction, signature);
      await truffleAssert.reverts(
        bridgePublicInstance.receiveFromPrivateBridge(userAddress, amount, nonce, direction, signature),
        "Provided nonce already exists in toPublicNonces"
      );
    });

    it("transaction successfully completed", async () => {
      // initialize
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, new BN(1000), new BN(10), false, gogoServiceAddrs];
      // get signature
      const signature = await getSignature(bridgePublicInstance, userAddress, amount, nonce, direction, signingAddress);
      // get address1 balance before
      const balanceBefore = await gogoPublicInstance.balanceOf(address1);
      // calling function
      const result = await bridgePublicInstance.receiveFromPrivateBridge(userAddress, amount, nonce, direction, signature);
      // get address1 balance after 
      const balanceAfter = await gogoPublicInstance.balanceOf(address1);
      // get toPublicNonces nonce value
      const isInPublicNonce = await bridgePublicInstance.toPublicNonces(nonce);
      // assertions
      truffleAssert.eventEmitted(result, "MintedToGoldToken", (event: any) => {
        return event.userAddress == userAddress && event.amount == amount.toString();
      });
      assert.isTrue(balanceAfter.sub(balanceBefore).eq(amount), "balance does not changed");
      assert.isTrue(isInPublicNonce, "toPublicNonces[nonce] should be true");
    });
  });

  describe("testing sendToPrivateBridge function", () => {
    it("should revert sentToPrivateBridge", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, new BN(1000), new BN(10), false, gogoServiceAddrs];
      const signature = await getSignature(bridgePublicInstance, userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePublicInstance.sendToPrivateBridge(userAddress, amount, nonce, direction, signature),
        "You can burn only your balance"
      );
    });

    it("direction must be true", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, new BN(1000), new BN(10), false, gogoServiceAddrs];
      const signature = await getSignature(bridgePublicInstance, userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePublicInstance.sendToPrivateBridge(userAddress, amount, nonce, direction, signature, {from: userAddress}),
        "direction must be true"
      );
    });

    it("signer must be gogoService", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, new BN(1000), new BN(10), true, address2];
      const signature = await getSignature(bridgePublicInstance, userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePublicInstance.sendToPrivateBridge(userAddress, amount, nonce, direction, signature, {from: userAddress}),
        "Recovered address is not gogoService address"
      );
    });

    it("amount must be allowed to contract for burning", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, new BN(1000), new BN(10), true, gogoServiceAddrs];
      const signature = await getSignature(bridgePublicInstance, userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePublicInstance.sendToPrivateBridge(userAddress, amount, nonce, direction, signature, {from: userAddress}),
        "ERC20: burn amount exceeds balance"
      );
    });

    describe("testing cases when required minting to address", () => {
      beforeEach("mint to address1 account", async () => {
        // initialize
        const [userAddress, amount, nonce, direction, signingAddress] 
          = [address1, new BN(1000), new BN(10), false, gogoServiceAddrs];
        // get signature
        const signature = await getSignature(bridgePublicInstance, userAddress, amount, nonce, direction, signingAddress);
        // calling function
        await bridgePublicInstance.receiveFromPrivateBridge(userAddress, amount, nonce, direction, signature);
      });

      it("cannot send to private bridge if nonce already used", async () => {
        // initialize
        const [userAddress, amount, nonce, direction, signingAddress] 
          = [address1, new BN(1000), new BN(10), true, gogoServiceAddrs];
        // get signature
        const signature = await getSignature(bridgePublicInstance, userAddress, amount, nonce, direction, signingAddress);
        // approve 
        await gogoPublicInstance.approve(bridgePublicInstance.address, amount, { from: address1 });
        // calling function
        await bridgePublicInstance.sendToPrivateBridge(userAddress, amount, nonce, direction, signature, {from: userAddress});
        await truffleAssert.reverts(
          bridgePublicInstance.sendToPrivateBridge(userAddress, amount, nonce, direction, signature, {from: userAddress}),
          "Provided nonce already exists in toPrivateNonces"
        );
      });

      it("transaction successfully completed", async () => {
        // initialize
        const [userAddress, amount, nonce, direction, signingAddress] 
          = [address1, new BN(1000), new BN(10), true, gogoServiceAddrs];
        // get signature
        const signature = await getSignature(bridgePublicInstance, userAddress, amount, nonce, direction, signingAddress);
        // get contract balance before
        const balanceBefore = await gogoPublicInstance.balanceOf(address1);
        // approve 
        await gogoPublicInstance.approve(bridgePublicInstance.address, amount, { from: address1 });
        // calling function
        const result = await bridgePublicInstance.sendToPrivateBridge(userAddress, amount, nonce, direction, signature, {from: userAddress});
        // get contract balance after 
        const balanceAfter = await gogoPublicInstance.balanceOf(address1);
        // get toPublicNonces nonce value
        const isInPrivateNonce = await bridgePublicInstance.toPrivateNonces(nonce);
        // assertions
        truffleAssert.eventEmitted(result, "BurnedFromGoldToken", (event: any) => {
          return event.userAddress == userAddress && event.amount == amount.toString();
        })
        assert.isTrue(balanceBefore.sub(balanceAfter).eq(amount), "balance does not changed");
        assert.isTrue(isInPrivateNonce, "toPrivateNonces[nonce] should be true");
      });
    })
  });
});
