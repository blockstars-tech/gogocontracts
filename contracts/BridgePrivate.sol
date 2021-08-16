// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract BridgePrivate {
    address public owner;
    // address of service that signs the transactions
    mapping(address => bool) isGogoService;
    // contract currency address
    IERC20 public currency;

    mapping(uint256 => bool) public toPublicNonces;

    mapping(uint256 => bool) public toPrivateNonces;

    modifier onlyOwner() {
        require(msg.sender == owner, "Function can call only owner");
        _;
    }

    // constructor
    constructor(IERC20 currency_) {
        currency = currency_;
        owner = msg.sender;
    }

    event AddedToPrivateBridge(address indexed userAddriess, uint256 amount);
    event TransferredBackToGogo(address indexed userAddress, uint256 amount);

    function addGogoServiceAddress(address gogoService) public onlyOwner {
        require(isGogoService[gogoService] == false, "GogoService already setted");
        isGogoService[gogoService] = true;
    }

    function removeGogoServiceAddress(address gogoService) public onlyOwner {
        require(isGogoService[gogoService] == true, "GogoService already removed");
        isGogoService[gogoService] = false;
    }

    function sendToPublicBridge(address userAddress_, uint256 amount_, uint256 nonce_) public {
        require(toPublicNonces[nonce_] == false, "nonce in toPublicNonces already exist");
        toPublicNonces[nonce_] = true;

        currency.transferFrom(userAddress_, address(this), amount_);
        emit AddedToPrivateBridge(userAddress_, amount_);
    }

    function receiveFromPublicBridge(address userAddress_, uint256 amount_, uint256 nonce_) public {
        require(isGogoService[msg.sender], "Function can call only gogoService");
        require(toPrivateNonces[nonce_] == false, "nonce in toPrivateNonces already exist");
        toPrivateNonces[nonce_] = true;

        currency.transfer(userAddress_, amount_);
        emit TransferredBackToGogo(userAddress_, amount_);
    }
}
