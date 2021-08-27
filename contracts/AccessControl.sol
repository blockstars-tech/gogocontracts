// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract AccessControl {
    event RoleGranted(uint8 role, address account, address admin);
    

    /// @notice Fee Decimals look like this: let's assume that you want set 1% transaction fee
    /// @notice well, the decimals are set to 6, so you should set fee equal to (1 * 10^6) to get 1% transaction fee
    /// @dev Later to calculate the %, given amount of trasaction fee will be divided by (10^6 * 100) (to get numeral part of percent)

    mapping(uint8 => uint32) public roleTxnFee;
    mapping(address => uint8) public addressToRole;

    uint8 public constant FEE_DECIMALS = 6;

    uint8 public constant USER = 0;            // DEFAULT
    uint8 public constant ADMIN = 1;           // OWNER
    uint8 public constant ROLE_1 = 2;          // CUSTOM_ROLE_1
    uint8 public constant ROLE_2 = 3;          // CUSTOM_ROLE_2
    uint8 public constant ROLE_3 = 4;          // CUSTOM_ROLE_3
    uint8 public constant ROLE_4 = 5;          // CUSTOM_ROLE_4
    uint8 public constant ROLE_5 = 6;          // CUSTOM_ROLE_5
    uint8 public constant ROLE_6 = 7;          // CUSTOM_ROLE_6
    uint8 public constant ROLE_7 = 8;          // CUSTOM_ROLE_7
    uint8 public constant ROLE_8 = 9;          // CUSTOM_ROLE_8

    event RoleTransactionFeeChanged(uint8 role, uint32 newTxhFee);

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyAdmin() {
        require(addressToRole[msg.sender] == ADMIN, "Function caller is not an ADMIN");
        _;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(uint8 role, address account) public onlyAdmin {
        require(addressToRole[account] != role, "account already has that role");
        _grantRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(uint8 role, address account) internal {
        _grantRole(role, account);
    }

    function _grantRole(uint8 role, address account) private {
        addressToRole[account] = role;
        emit RoleGranted(role, account, msg.sender);
    }

    /// @notice Sets given transaction fee to the role
    /// @param role The uint32 role.
    /// @param txhFee The amount of fee in percent.
    function setRoleTxnFee(uint8 role, uint32 txhFee) public onlyAdmin {
        require(txhFee <= 100000000, "[Transaction Fee]: Fee cannot be more than 100%");

        roleTxnFee[role] = txhFee;

        emit RoleTransactionFeeChanged(role, txhFee);
    }
}