const assert = require("chai").assert;
const truffleAssert = require("truffle-assertions");

const keys = require("./keys.json");

const GogoPrivate = artifacts.require("GogoPrivate");
const BridgePrivate = artifacts.require("BridgePrivate");

contract("BridgePrivate", async (accounts) => {
  // account addresses
  const [contractOwnerAddr, gogoServiceAddrs, address1, address2] = accounts;
  // bridge instance
  let bridgePrivateInstance;
  // goldTokenInstance
  let gogoPrivateInstance;
  // get signature 
  const getSignature = async (userAddress, amount, nonce, direction, signingAddress) => {
    const data = await bridgePrivateInstance.formSigningData(userAddress, amount, nonce, direction);
    const privateKey = keys.private_keys[signingAddress.toLowerCase()];
    const { signature } = await web3.eth.accounts.sign(data, privateKey);
    return signature;
  };

  beforeEach("Deploy GogoPrivate and BridgePrivate Contracts", async () => {
    gogoPrivateInstance = await GogoPrivate.new("GogoPrivate", "GP", { from: contractOwnerAddr, });
    bridgePrivateInstance = await BridgePrivate.new(
      gogoPrivateInstance.address,
      gogoServiceAddrs,
      { from: contractOwnerAddr }
    );
    const tokenAmount = 10000;
    await gogoPrivateInstance.mint(address1, tokenAmount);
    await gogoPrivateInstance.mint(address2, tokenAmount);
  });

  describe("testing sendToPublicBridge function", () => {
    it("direction must be false", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, true, gogoServiceAddrs];
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePrivateInstance.sendToPublicBridge(userAddress, amount, nonce, direction, signature),
        "direction must be false"
      );
    });

    it("signer must be gogoService", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, false, address2];
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePrivateInstance.sendToPublicBridge(userAddress, amount, nonce, direction, signature),
        "recovered address is not gogoService address"
      );
    });

    it("amount must be allowed to contract for sending", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, false, gogoServiceAddrs];
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePrivateInstance.sendToPublicBridge(userAddress, amount, nonce, direction, signature),
        "ERC20: transfer amount exceeds allowance"
      );
    });

    it("cannot send to public bridge if nonce already used", async () => {
      // initialize
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, false, gogoServiceAddrs];
      // get signature
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      // approve 
      await gogoPrivateInstance.approve(bridgePrivateInstance.address, amount, { from: address1 });
      // calling function
      await bridgePrivateInstance.sendToPublicBridge(userAddress, amount, nonce, direction, signature);
      await truffleAssert.reverts(
        bridgePrivateInstance.sendToPublicBridge(userAddress, amount, nonce, direction, signature),
        "nonce in toPublicNonces already exist"
      );
    });

    it("transaction successfully completed", async () => {
      // initialize
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, false, gogoServiceAddrs];
      // get signature
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      // get contract balance before
      const balanceBefore = await gogoPrivateInstance.balanceOf(bridgePrivateInstance.address);
      // approve 
      await gogoPrivateInstance.approve(bridgePrivateInstance.address, amount, { from: address1 });
      // calling function
      const result = await bridgePrivateInstance.sendToPublicBridge(userAddress, amount, nonce, direction, signature);
      // get contract balance after 
      const balanceAfter = await gogoPrivateInstance.balanceOf(bridgePrivateInstance.address);
      // get toPublicNonces nonce value
      const isInPublicNonce = await bridgePrivateInstance.toPublicNonces(nonce);
      // assertions
      truffleAssert.eventEmitted(result, "AddedToPrivateBridge", (event) => {
        return event.userAddress == userAddress && event.amount == amount;
      })
      assert.equal(balanceAfter - balanceBefore, amount, "balance does not changed");
      assert.isTrue(isInPublicNonce, "toPublicNonces[nonce] should be true");
    });
  });

  describe("testing receiveFromPublicBridge function", () => {
    it("direction must be true", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, false, gogoServiceAddrs];
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePrivateInstance.receiveFromPublicBridge(userAddress, amount, nonce, direction, signature),
        "direction must be true"
      );
    });

    it("signer must be gogoService", async () => {
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, true, address2];
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      await truffleAssert.reverts(
        bridgePrivateInstance.receiveFromPublicBridge(userAddress, amount, nonce, direction, signature),
        "recovered address is not gogoService address"
      );
    });

    it("cannot receive from public bridge if nonce already used", async () => {
      // initialize
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, true, gogoServiceAddrs];
      // get signature
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      // transfer to contract address 1000 tokens for having balance
      await gogoPrivateInstance.mint(bridgePrivateInstance.address, amount);
      // calling function
      await bridgePrivateInstance.receiveFromPublicBridge(userAddress, amount, nonce, direction, signature);
      await truffleAssert.reverts(
        bridgePrivateInstance.receiveFromPublicBridge(userAddress, amount, nonce, direction, signature),
        "nonce in toPrivateNonces already exist"
      );
    });

    it("transaction successfully completed", async () => {
      // initialize
      const [userAddress, amount, nonce, direction, signingAddress] 
        = [address1, 1000, 10, true, gogoServiceAddrs];
      // get signature
      const signature = await getSignature(userAddress, amount, nonce, direction, signingAddress);
      // transfer to contract address 1000 tokens for having balance
      await gogoPrivateInstance.mint(bridgePrivateInstance.address, amount);
      // get contract balance before
      const balanceBefore = await gogoPrivateInstance.balanceOf(bridgePrivateInstance.address);
      // calling function
      const result = await bridgePrivateInstance.receiveFromPublicBridge(userAddress, amount, nonce, direction, signature);
      // get contract balance after 
      const balanceAfter = await gogoPrivateInstance.balanceOf(bridgePrivateInstance.address);
      // get toPublicNonces nonce value
      const isInPrivateNonce = await bridgePrivateInstance.toPrivateNonces(nonce);
      // assertions
      truffleAssert.eventEmitted(result, "TransferredBackToGogo", (event) => {
        return event.userAddress == userAddress && event.amount == amount;
      })
      assert.equal(balanceBefore - balanceAfter, amount, "balance does not changed");
      assert.isTrue(isInPrivateNonce, "toPrivateNonces[nonce] should be true");
    });
  });
});
