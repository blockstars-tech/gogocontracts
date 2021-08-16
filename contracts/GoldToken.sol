// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./BridgePublic.sol";

contract GoldToken is ERC20 {
    BridgePublic public bridgeAddress;
    address public contractOwner;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        contractOwner = _msgSender();
    }

    function decimals() public pure override returns (uint8) {
        return 0;
    }

    function setBridgeAddress(BridgePublic bridgeAddress_) public {
        require(address(bridgeAddress) == address(0), "Bridge address is already setted");
        require(_msgSender() == contractOwner, "Function can call only contract owner");
        bridgeAddress = bridgeAddress_;
    }

    function mint(address to_, uint256 amount_) public {
        require(_msgSender() == address(bridgeAddress), "Function can call only bridge");
        _mint(to_, amount_);
    }

    function burn(address userAddress_, uint256 amount_) public {
        require(_msgSender() == address(bridgeAddress), "Function can call only bridge");
        uint256 currentAllowance = allowance(userAddress_, _msgSender());
        require(currentAllowance >= amount_, "ERC20: burn amount_ exceeds allowance");
        _approve(userAddress_, _msgSender(), currentAllowance - amount_);
        _burn(userAddress_, amount_);
    }
}