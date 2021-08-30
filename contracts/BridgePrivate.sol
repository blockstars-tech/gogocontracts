// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract BridgePrivate {
    // Decalring state variable for contract owner    
    address public owner;

    // Adding the library methods
    using EnumerableSet for EnumerableSet.AddressSet;

    // Declaring a set state variable of address tht signs the transactions
    EnumerableSet.AddressSet private gogoServices;

    mapping(uint256 => bool) public toPublicNonces;

    mapping(uint256 => bool) public toPrivateNonces;

    // Declaring variable for currency contract
    IERC20 public currency;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // constructor
    constructor(IERC20 currency_) {
        currency = currency_;
        owner = msg.sender;
    }

    event AddedToPrivateBridge(address indexed userAddriess, uint256 amount);
    event TransferredBackToGogo(address indexed userAddress, uint256 amount);

    function getGogoServicesList() public view returns(address[] memory) {
        return gogoServices.values();
    }

    function getGogoServicesCount() public view returns(uint256) {
        return gogoServices.length();
    }

    function getGogoServicesByIndex(uint256 index) public view returns(address) {
        return gogoServices.at(index);
    }

    function addGogoServiceAddress(address gogoService) public onlyOwner {
        require(!gogoServices.contains(gogoService), "Provided GogoService address already set");
        gogoServices.add(gogoService);
    }

    function removeGogoServiceAddress(address gogoService) public onlyOwner {
        require(gogoServices.contains(gogoService), "Provided GogoService address is already removed");
        gogoServices.remove(gogoService);
    }

    function sendToPublicBridge(address userAddress_, uint256 amount_, uint256 nonce_) public {
        require(!toPublicNonces[nonce_], "nonce already exists in toPublicNonces");
        toPublicNonces[nonce_] = true;

        currency.transferFrom(userAddress_, address(this), amount_);
        emit AddedToPrivateBridge(userAddress_, amount_);
    }

    function receiveFromPublicBridge(address userAddress_, uint256 amount_, uint256 nonce_) public {
        require(gogoServices.contains(msg.sender), "Only gogoService can call this function");
        require(!toPrivateNonces[nonce_], "Provided nonce already exists in toPrivateNonces");
        toPrivateNonces[nonce_] = true;

        currency.transfer(userAddress_, amount_);
        emit TransferredBackToGogo(userAddress_, amount_);
    }
}
