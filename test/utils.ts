import { BridgePublicInstance, GoldTokenInstance } from "../typechain";

const keys = require("./keys.json");

export const getSignature = async (
  bridgePublicInstance: BridgePublicInstance,
  userAddress: string,
  amount: BN,
  nonce: BN,
  direction: boolean,
  signingAddress: string
) => {
  const data = await bridgePublicInstance.formSigningData(
    userAddress,
    amount,
    nonce,
    direction
  );
  const privateKey = keys.private_keys[signingAddress.toLowerCase()];
  const { signature } = await web3.eth.accounts.sign(data, privateKey);
  return signature;
};

export const mint = async (
  bridgePublicInstance: BridgePublicInstance,
  userAddress: string,
  amount: BN,
  nonce: BN,
  signature: string
) => {
  return bridgePublicInstance.receiveFromPrivateBridge(userAddress, amount, nonce, false, signature);
};

export const signAndMint = async (
  bridgePublicInstance: BridgePublicInstance,
  userAddress: string,
  amount: BN,
  nonce: BN,
  signingAddress: string
) => {
  const signature = await getSignature(bridgePublicInstance, userAddress, amount, nonce, false, signingAddress);
  return mint(bridgePublicInstance, userAddress, amount, nonce, signature);
}