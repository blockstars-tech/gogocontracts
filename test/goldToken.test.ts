import {
  BridgePublicContract,
  BridgePublicInstance,
  GoldTokenContract,
  GoldTokenInstance,
} from "../typechain";
import { assert } from "chai";
import BN from "bn.js";
import { signAndMint } from "./utils";

const truffleAssert = require("truffle-assertions");

const GoldToken: GoldTokenContract = artifacts.require("GoldToken");
const BridgePublic: BridgePublicContract = artifacts.require("BridgePublic");

contract("GoldToken", async (accounts) => {
  // account addresses
  const [
    contractOwnerAddr,
    gogoServiceAddrs,
    address1,
    address2,
    feeCollector,
  ]: string[] = accounts;
  // bridge instance
  let bridgePublicInstance: BridgePublicInstance;
  // goldTokenInstance
  let gogoPublicInstance: GoldTokenInstance;

  beforeEach("Deploying GoldToken and BridgePublic contracts", async () => {
    gogoPublicInstance = await GoldToken.new("Token", "TKN", {
      from: contractOwnerAddr,
    });
    bridgePublicInstance = await BridgePublic.new(gogoPublicInstance.address, {
      from: contractOwnerAddr,
    });

    await bridgePublicInstance.addGogoServiceAddress(gogoServiceAddrs, {
      from: contractOwnerAddr,
    });
    await gogoPublicInstance.setBridgeAddress(bridgePublicInstance.address, {
      from: contractOwnerAddr,
    });
  });

  it("Should have 18 decimals", async () => {
    const decimals = await gogoPublicInstance.decimals();
    assert.isTrue(decimals.eqn(18));
  });

  describe("testing setBridgeAddress function", () => {
    it("Only ADMIN can call this function", async () => {
      await truffleAssert.reverts(
        gogoPublicInstance.setBridgeAddress(bridgePublicInstance.address, {
          from: address1,
        }),
        "Function caller is not an ADMIN"
      );
    });

    it("Cannot change Bridge Address if it is already set", async () => {
      await truffleAssert.reverts(gogoPublicInstance.setBridgeAddress(bridgePublicInstance.address, {
        from: contractOwnerAddr,
      }), "Provided address is current bridge address");
      
    });

  });

  it("mint function can call only bridge", async () => {
    await truffleAssert.reverts(
      gogoPublicInstance.mint(address2, 10000, { from: address1 }),
      "Only Bridge can call this function"
    );
  });

  it("burn function can call only bridge", async () => {
    await truffleAssert.reverts(
      gogoPublicInstance.burn(address2, 10000, { from: address1 }),
      "Only Bridge can call this function"
    );
  });

  it("should collect transaction fee", async () => {
    const ROLE_2 = 2;

    await gogoPublicInstance.setRoleTxnFee(ROLE_2, new BN(10000000), {
      from: contractOwnerAddr,
    });
    await gogoPublicInstance.grantRole(ROLE_2, address1, {
      from: contractOwnerAddr,
    });
    await gogoPublicInstance.setTransactionFeeCollector(feeCollector, {
      from: contractOwnerAddr,
    });
    await signAndMint(
      bridgePublicInstance,
      contractOwnerAddr,
      new BN(100).mul(new BN(10).pow(new BN(18))),
      new BN(0),
      gogoServiceAddrs
    );

    const transferAmount = new BN(10000);
    const ROLE2txhFee = await gogoPublicInstance.roleTxnFee(ROLE_2, {
      from: address1,
    });
    
    await gogoPublicInstance.transfer(address1, transferAmount, {
      from: contractOwnerAddr,
    });
    const address2BalanceBefore = await gogoPublicInstance.balanceOf(address2);
    const feeCollectorBalanceBefore = await gogoPublicInstance.balanceOf(feeCollector);
    
    await gogoPublicInstance.transfer(address2, transferAmount, { from: address1 });
    const address2BalanceAfter = await gogoPublicInstance.balanceOf(address2);
    const feeCollectorBalanceAfter = await gogoPublicInstance.balanceOf(feeCollector);
    assert.isTrue(
      address2BalanceBefore
        .add(transferAmount.sub(transferAmount.mul(ROLE2txhFee).div(new BN(100000000))))
        .eq(address2BalanceAfter),
      "Balances aren't equal after transfer"
    );
    assert.isTrue(
      feeCollectorBalanceBefore
        .add(transferAmount.mul(ROLE2txhFee).div(new BN(100000000)))
        .eq(feeCollectorBalanceAfter),
      "Fee Collector balances aren't equal after transfer"
    );
  });
  describe("totalSupply functionalty tests", async () => {
    it("should return zero total supply", async () => {
      const totalSupply = await gogoPublicInstance.totalSupply();

      assert.isTrue(totalSupply.eqn(0), "Initial supply balance should be 0");
    });

    it("should return right total supply after mint", async () => {
      const tokenAmount = new BN(100);
      const ten = new BN(10);

      let totalSupplyBefore = await gogoPublicInstance.totalSupply();

      await signAndMint(
        bridgePublicInstance,
        contractOwnerAddr,
        new BN(100).mul(new BN(10).pow(new BN(18))),
        new BN(0),
        gogoServiceAddrs
      );
    
      let totalSupplyAfter = await gogoPublicInstance.totalSupply();

      assert.isTrue(
        totalSupplyAfter.eq(
          totalSupplyBefore.add(tokenAmount.mul(ten.pow(new BN(18))))
        ),
        "Total supplies are not equal."
      );

      assert.isTrue(
        totalSupplyBefore
          .add(tokenAmount.mul(ten.pow(new BN(18))))
          .eq(totalSupplyAfter),
        "Total supplies are not equal"
      );
    });
    
    it("should return right txn fee", async() => {
      await gogoPublicInstance.setRoleTxnFee(0, new BN(10000000), {from: contractOwnerAddr});
      
      await signAndMint(
        bridgePublicInstance,
        contractOwnerAddr,
        new BN(100).mul(new BN(10).pow(new BN(18))),
        new BN(0),
        gogoServiceAddrs
      );

      
      const transferAmount = 1000000;
      await gogoPublicInstance.transfer(address1, new BN(transferAmount), {from: contractOwnerAddr});
      await gogoPublicInstance.setTransactionFeeCollector(feeCollector, {from: contractOwnerAddr});
      await gogoPublicInstance.transfer(address2, new BN(transferAmount), {from: address1});
      
      const txnFee = await gogoPublicInstance.roleTxnFee(0);
      const decimals = await gogoPublicInstance.FEE_DECIMALS();

      const transactionCost = await gogoPublicInstance.balanceOf(feeCollector);
      assert.isTrue(transactionCost.eq(new BN(transferAmount).mul(txnFee).div(new BN(10).pow(decimals).muln(100))), "FeeCost is correct");
      
    })
    
    it("cannot call sendToPrivteBridge with the same nonce", async () => {
      await signAndMint(
        bridgePublicInstance,
        address1,
        new BN(100000),
        new BN(1),
        gogoServiceAddrs
      );
      await truffleAssert.reverts(
        signAndMint(
          bridgePublicInstance,
          address2,
          new BN(100000),
          new BN(1),
          gogoServiceAddrs
        ),
        "Provided nonce already exists in toPublicNonces"
      );
    })
  });
});
