// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IERC20MintBurn is IERC20Metadata {
	function mint(address to, uint256 amount) external;

	function burn(address userAddress, uint256 amount) external;
} 