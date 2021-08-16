// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./IERC20MintBurn.sol";

contract BridgePublic {
    mapping(uint256 => bool) public toPublicNonces;

    mapping(uint256 => bool) public toPrivateNonces;

    // address of service that signs the transactions
    mapping(address => bool) isGogoService;
    // address of contract creator
    address public owner;
    // GoldToken address
    IERC20MintBurn public token;

    modifier onlyOwner() {
        require(msg.sender == owner, "Function can call only owner");
        _;
    }

    constructor(IERC20MintBurn token_) {
        token = token_;
        owner = msg.sender;
    }

    event MintedToGoldToken(address indexed userAddress, uint256 amount);
    event BurnedFromGoldToken(address indexed userAddress, uint256 amount);

    function addGogoServiceAddress(address gogoService) public onlyOwner {
        require(isGogoService[gogoService] == false, "GogoService already setted");
        isGogoService[gogoService] = true;
    }

    function removeGogoServiceAddress(address gogoService) public onlyOwner {
        require(isGogoService[gogoService] == true, "GogoService already removed");
        isGogoService[gogoService] = false;
    }

    function receiveFromPrivateBridge(address userAddress_, uint256 amount_, uint256 nonce_, bool direction_, bytes memory signature_) public {
        require(direction_ == false, "direction must be false");
        require(isGogoService[recoverSigner(userAddress_, amount_, nonce_, direction_, signature_)], "recovered address is not gogoService address");

        require(toPublicNonces[nonce_] == false, "nonce in toPublicNonces already exist");
        toPublicNonces[nonce_] = true;

        token.mint(userAddress_, amount_);
        emit MintedToGoldToken(userAddress_, amount_);
    }

    function sendToPrivateBridge(address userAddress_, uint256 amount_, uint256 nonce_, bool direction_, bytes memory signature_) public {
        require(direction_ == true, "direction must be true");
        require(isGogoService[recoverSigner(userAddress_, amount_, nonce_, direction_, signature_)], "recovered address is not gogoService address");

        require(toPrivateNonces[nonce_] == false, "nonce in toPrivateNonces already exist");
        toPrivateNonces[nonce_] = true;

        token.burn(userAddress_, amount_);
        emit BurnedFromGoldToken(userAddress_, amount_);
    }

    function formSigningData(address userAddress_, uint256 amount_, uint256 nonce_, bool direction_) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("GOGOBridgeV1", userAddress_, amount_, nonce_, direction_));
    }

    function recoverSigner(address userAddress_, uint256 amount_, uint256 nonce_, bool direction_, bytes memory signature_) public pure returns (address) {
        bytes32 dataHash__ = formSigningData(userAddress_, amount_, nonce_, direction_);

        return ECDSA.recover(ECDSA.toEthSignedMessageHash(dataHash__), signature_);
    }
}
