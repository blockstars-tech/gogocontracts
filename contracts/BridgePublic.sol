// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./IERC20MintBurn.sol";

contract BridgePublic {
    // Declaring state vaiable of contract owner
    address public owner;

    // Adding the library methods
    using EnumerableSet for EnumerableSet.AddressSet;

    // Declaring a set state variable of address tht signs the transactions
    EnumerableSet.AddressSet private gogoServices;

    mapping(uint256 => bool) public toPublicNonces;

    mapping(uint256 => bool) public toPrivateNonces;

    // Declaring varibale for token address
    IERC20MintBurn public token;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(IERC20MintBurn token_) {
        token = token_;
        owner = msg.sender;
    }

    event MintedToGoldToken(address indexed userAddress, uint256 amount);
    event BurnedFromGoldToken(address indexed userAddress, uint256 amount);

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
        require(gogoServices.contains(gogoService) == false, "Provided GogoService address is already set");
        gogoServices.add(gogoService);
    }

    function removeGogoServiceAddress(address gogoService) public onlyOwner {
        require(gogoServices.contains(gogoService) == true, "Provided GogoService address is already removed");
        gogoServices.remove(gogoService);
    }

    function receiveFromPrivateBridge(address userAddress_, uint256 amount_, uint256 nonce_, bool direction_, bytes memory signature_) public {
        require(!direction_, "direction must be false");
        require(gogoServices.contains(recoverSigner(userAddress_, amount_, nonce_, direction_, signature_)), "Recovered address is not gogoService address");

        require(!toPublicNonces[nonce_], "Provided nonce already exists in toPublicNonces");
        toPublicNonces[nonce_] = true;

        token.mint(userAddress_, amount_);
        emit MintedToGoldToken(userAddress_, amount_);
    }

    function sendToPrivateBridge(address userAddress_, uint256 amount_, uint256 nonce_, bool direction_, bytes memory signature_) public {
        require(msg.sender == userAddress_, "You can burn only your balance");

        require(direction_, "direction must be true");
        require(gogoServices.contains(recoverSigner(userAddress_, amount_, nonce_, direction_, signature_)), "Recovered address is not gogoService address");

        require(!toPrivateNonces[nonce_], "Provided nonce already exists in toPrivateNonces");
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
