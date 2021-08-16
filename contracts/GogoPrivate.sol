
// File: openzeppelin-solidity/contracts/GSN/Context.sol
//v1.3

pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.0;


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.0;
/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: contracts/AccountTyped.sol

pragma solidity 0.5.16;


/**
 * @title Provides methods related to Account Types (role) management
 * @author Jayson Cheng
 */

contract AccountTyped {
    // fees read and stored as x * 10^(FEE_DECIMALS)
    // e.g. for 5% fee (i.e. 0.05), read and stored: 5 * 10^6 = 5000000;
    struct AccountType {
        bool exists;
        uint8 index;
        bytes32 name;
        uint32 holdingFee;
        uint32[] txnFeesAsSender;
    }
    AccountType[] private accountTypes;
    // map acctType hash to storage array position
    mapping(bytes32 => uint256) private accountTypeIndexByName;
    mapping(address => uint256) private accountTypeIndexByAddress;

    constructor(address _root) internal {
        // Biz requirements says to keep it configurable, i.e. additional roles can be added
        // depend on gas, either do initialization in constructor or separated, one use method
        addAcctTypeWithDefaults("USER"); // 0
        addAcctTypeWithDefaults("ROOT"); // 1
        addAcctTypeWithDefaults("ADMIN"); // 2
        addAcctTypeWithDefaults("OPERATOR"); // 3
        addAcctTypeWithDefaults("HOLDING"); // 4
        addAcctTypeWithDefaults("MINTER"); // 5
        addAcctTypeWithDefaults("BURN"); // 6
        addAcctTypeWithDefaults("MERCHANT"); // 7
        accountTypeIndexByAddress[_root] = 1; // ROOT user must exist
    }

    /**
     * @notice Modify settings relating to target account type.
     * Only Role: ADMIN
     * @dev There is no validation on the fees, can be added if needed
     * @param _index Index of target account type, as stored in array `AccountTypes`
     * @param _holdingFee new holding fee for target account type
     * @param _txnFeesAsSender new txn fees for target account type to all other account types
     */
    function setAcctTypeDetails(
        uint8 _index,
        uint32 _holdingFee,
        uint32[] memory _txnFeesAsSender
    ) public onlyAcctType("ADMIN") {
        require(_index < accountTypes.length, "Target type does not exist");
        require(
            _txnFeesAsSender.length ==
                accountTypes[_index].txnFeesAsSender.length,
            "Txn fee to all types needed"
        );
        accountTypes[_index].holdingFee = _holdingFee;
        accountTypes[_index].txnFeesAsSender = _txnFeesAsSender;
    }

    /**
     * @notice Modify only txn fee for sender account type to receiver account type
     * Only Role: ADMIN
     * @dev There is no validation on the fees, can be added if needed
     * @param _srcIndex index of target sender account type, as stored in array `AccountTypes`
     * @param _destIndex index of target receiver account type, as stored in array `AccountTypes`
     * @param _txnFee new txn fee for sender account type to receiver account type
     */
    function setAcctTypeTxnFee(
        uint8 _srcIndex,
        uint8 _destIndex,
        uint32 _txnFee
    ) public onlyAcctType("ADMIN") {
        require(accountTypes[_srcIndex].exists, "Source type does not exist");
        require(
            accountTypes[_destIndex].exists,
            "Destination type does not exist"
        );
        accountTypes[_srcIndex].txnFeesAsSender[_destIndex] = _txnFee;
        emitAccountTypeChangeEvent(accountTypes[_srcIndex]);
    }

    function addAcctTypeWithDefaults(bytes32 _name) private {
        // set fees for transactions from existing types to new type
        for (uint256 i = 0; i < accountTypes.length; i++) {
            accountTypes[i].txnFeesAsSender.push(0);
        }
        AccountType memory newAccountType;
        newAccountType.exists = true;
        newAccountType.index = uint8(accountTypes.length);
        newAccountType.name = _name;
        uint32[] memory fees = new uint32[](accountTypes.length + 1);
        newAccountType.txnFeesAsSender = fees;

        // add details of new type
        accountTypeIndexByName[_name] = accountTypes.length;
        accountTypes.push(newAccountType);
        emitAccountTypeChangeEvent(accountTypes[accountTypes.length - 1]);
    }

    /**
     * @notice Add new account type
     * Only Role: ADMIN
     * @dev There is no validation on the fees, can be added if needed
     * @param _name name of new account type
     * @param _holdingFee holding fee for new account type
     * @param _txnFeesAsSender txn fee for new account type (send) to all account types (receive), including this new account type
     * @param _txnFeesAsReceiver txn fee for all existing account types (send) to new account type (receive)
     */
    function addAcctType(
        string memory _name,
        uint32 _holdingFee,
        uint32[] memory _txnFeesAsSender,
        uint32[] memory _txnFeesAsReceiver
    ) public onlyAcctType("ADMIN") {
        require(
            _txnFeesAsSender.length == accountTypes.length + 1,
            "Txn fee to all types needed"
        );
        require(
            _txnFeesAsReceiver.length == accountTypes.length,
            "Txn fee from all ex types needed"
        );

        // set fees for transactions from existing types to new type
        for (uint256 i = 0; i < accountTypes.length; i++) {
            accountTypes[i].txnFeesAsSender.push(_txnFeesAsReceiver[i]);
        }

        // add details of new type
        bytes32 nameInBytes = stringToBytes32(_name);
        accountTypeIndexByName[nameInBytes] = accountTypes.length;
        accountTypes.push(
            AccountType({
                exists: true,
                index: uint8(accountTypes.length),
                name: nameInBytes,
                holdingFee: _holdingFee,
                txnFeesAsSender: _txnFeesAsSender
            })
        );
        emitAccountTypeChangeEvent(accountTypes[accountTypes.length - 1]);
    }

    modifier onlyAcctType(string memory _type) {
        require(
            accountTypeIndexByAddress[msg.sender] ==
                accountTypeIndexByName[stringToBytes32(_type)],
            "Sender does not have required account type"
        );
        _;
    }

    /**
     * @notice Set account type for provided addresses. cannot be used to set ADMIN, ROOT, MINTER type
     * Only Role: ADMIN
     * @param _addr addresses that needs account type change
     * @param _type name of new account type
     */
    function setAcctTypeForAddrs(address[] memory _addr, string memory _type)
        public
        onlyAcctType("ADMIN")
    {
        bytes32 byteName = stringToBytes32(_type);
        require(
            byteName != stringToBytes32("ROOT") &&
                byteName != stringToBytes32("ADMIN"),
            "Cannot add ROOT and ADMIN"
        );
        require(
            byteName != stringToBytes32("MINTER"),
            "Use addMinter method instead"
        );
        AccountType storage targetType = getAcctTypeByName(byteName);
        require(targetType.exists, "Invalid account type");
        for (uint256 i = 0; i < _addr.length; i++) {
            setAcctType(_addr[i], targetType);
        }
    }

    /**
     * @notice Force set account type for provided addresses
     * Only Role: ROOT
     * @param _addr addresses that needs account type change
     * @param _type name of new account type
     */
    function setAcctTypeWithRoot(address[] memory _addr, string memory _type)
        public
        onlyAcctType("ROOT")
    {
        bytes32 byteName = stringToBytes32(_type);
        AccountType storage targetType = getAcctTypeByName(byteName);
        require(targetType.exists, "Invalid account type");
        for (uint256 i = 0; i < _addr.length; i++) {
            setAcctType(_addr[i], targetType);
        }
    }

    /**
     * @dev Allows internal functions to set types of target address
     * no validation except ROOT
     */
    function setAcctType(address _addr, AccountType storage _targetType)
        internal
    {
        require(_targetType.exists, "Account Type does not exist");
        require(
            _targetType.name != stringToBytes32("ROOT") || _addr != msg.sender,
            "ROOT cannot remove yourself"
        );
        accountTypeIndexByAddress[_addr] = _targetType.index;
        emit AddressAccountTypeChanged(
            _addr,
            _targetType.name,
            _targetType.index
        );
    }

    /**
     * @notice Get account type index of target address, as stored in array `AccountTypes`
     * @param _addr addresses that needs account type change
     */
    function getAcctTypeIndexByAddr(address _addr)
        public
        view
        returns (uint256)
    {
        return accountTypeIndexByAddress[_addr];
    }

    function getAcctTypeByAddr(address _addr)
        internal
        view
        returns (AccountType storage)
    {
        return accountTypes[accountTypeIndexByAddress[_addr]];
    }

    function getAcctTypeByName(bytes32 _type)
        internal
        view
        returns (AccountType storage)
    {
        return accountTypes[accountTypeIndexByName[_type]];
    }

    function getAcctTypeByIndex(uint256 _index)
        internal
        view
        returns (AccountType storage)
    {
        return accountTypes[_index];
    }

    /**
     * @notice Get transaction fee rate (6 decimal) from _src (string) type to _dest (string) type
     * @param _src sender address
     * @param _dest receiver address
     */
    function getRate(string memory _src, string memory _dest)
        public
        view
        returns (uint32)
    {
        return getRateByBytes32(stringToBytes32(_src), stringToBytes32(_dest));
    }

    /**
     * @notice Get transaction fee rate (6 decimal) from _from address to _to address
     * @param _src sender address
     * @param _dest receiver address
     */
    function getRateByAddress(address _src, address _dest)
        public
        view
        returns (uint32)
    {
        return
            accountTypes[accountTypeIndexByAddress[_src]]
                .txnFeesAsSender[accountTypeIndexByAddress[_dest]];
    }


        /**
     * @notice Get transaction fee rate (6 decimal) from _from address to _to address
     * @param _senderIndex sender account index
     * @param _receipientIndex receiver account index
     */
    function getTxnFeeByAcctType(uint256 _senderIndex, uint256 _receipientIndex)
        public
        view
        returns (uint32)
    {
        return
            accountTypes[_senderIndex]
                .txnFeesAsSender[_receipientIndex];
    }

        /**
     * @notice Get transaction fee rate (6 decimal) from _from address to _to address
     * @param _index account index
     */
    function getHoldingFeeByAcctType(uint256 _index)
        public
        view
        returns (uint32)
    {
        return
                accountTypes[_index].holdingFee;
    }

      /**
     * @notice Get transaction fee rate (6 decimal) from _src (bytes32) type to _dest (bytes32) type
     * @param _src sender address
     * @param _dest receiver address
     */
    function getRateByBytes32(bytes32 _src, bytes32 _dest)
        internal
        view
        returns (uint32)
    {
        return
            accountTypes[accountTypeIndexByName[_src]]
                .txnFeesAsSender[accountTypeIndexByName[_dest]];
    }

    /**
     * @notice Convert string to bytes32
     * @param _source input string
     */
    function stringToBytes32(string memory _source)
        public
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(_source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(_source, 32))
        }
    }

    /**
     * @dev Emit event for any change in account type
     * @param _type the target account type to be logged
     */
    function emitAccountTypeChangeEvent(AccountType storage _type) private {
        emit AccountTypeDetailsChanged(
            _type.exists,
            _type.index,
            _type.name,
            _type.holdingFee,
            _type.txnFeesAsSender
        );
    }

    event AccountTypeDetailsChanged(
        bool exists,
        uint8 indexed index,
        bytes32 indexed name,
        uint32 holdingFee,
        uint32[] txnFeesAsSender
    );

    event AddressAccountTypeChanged(
        address indexed addr,
        bytes32 indexed name,
        uint256 indexed roleIndex
    );
}

// File: contracts/Pausable.sol

pragma solidity 0.5.16;

contract Pausable is AccountTyped {
    bool public paused = true;
    bool public pausePending = false;
    bool public unpausePending = false;

    /**
     * @notice Request to pause contract
     * Only Role: ADMIN
     */
    function requestPause() public onlyAcctType("ADMIN") {
        pausePending = true;
        unpausePending = false;
    }

    /**
     * @notice Request to unpause contract
     * Only Role: ADMIN
     */
    function requestUnpause() public onlyAcctType("ADMIN") {
        pausePending = false;
        unpausePending = true;
    }

    /**
     * @notice Cancel pause request
     * Only Role: ADMIN
     */
    function cancelRequestPause() public onlyAcctType("ADMIN") {
        pausePending = false;
    }

    /**
     * @notice Approve pause request
     * Only Role: ADMIN
     */
    function approveRequestPause() public onlyAcctType("ADMIN") {
        require(pausePending, "No pause request to approve");
        pausePending = false;
        paused = true;
    }

    /**
     * @notice Reject pause request
     * Only Role: ADMIN
     */
    function rejectRequestPause() public onlyAcctType("ADMIN") {
        pausePending = false;
    }

    /**
     * @notice Cancel unpause request
     * Only Role: ADMIN
     */
    function cancelRequestUnpause() public onlyAcctType("ADMIN") {
        unpausePending = false;
    }

    /**
     * @notice Approve unpause request
     * Only Role: ADMIN
     */
    function approveRequestUnpause() public onlyAcctType("ADMIN") {
        require(unpausePending, "No unpause request to approve");
        unpausePending = false;
        paused = false;
    }

    /**
     * @notice Reject unpause request
     * Only Role: ADMIN
     */
    function rejectRequestUnpause() public onlyAcctType("ADMIN") {
        unpausePending = false;
    }

    /**
     * @dev Throws if called by any account other than specified role.
     */
    modifier whenPaused() {
        require(paused, "Contract not paused");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract paused");
        _;
    }
}

// File: contracts/Whitelistable.sol

pragma solidity 0.5.16;

/**
 * @title Provides methods relating to Whitelist management
 * @author Jayson Cheng
 */
contract Whitelistable is AccountTyped {
    // mapping of addresses' kyc status
    mapping(address => bool) public whitelisted;

    /**
     * @notice Whitelist provided addresses
     * Only Role: ADMIN
     * @param _addr target addresses
     */
    function whitelistAddresses(address[] memory _addr)
        public
        onlyAcctType("OPERATOR")
    {
        for (uint256 i = 0; i < _addr.length; i++) {
            if (!whitelisted[_addr[i]]) {
                whitelisted[_addr[i]] = true;
                emit WhitelistStatusModified(_addr[i], true);
            }
        }
    }

    /**
     * @notice Blacklist (remove from whitelist) provided addresses
     * Only Role: ADMIN
     * @param _addr target addresses
     */
    function blacklistAddresses(address[] memory _addr)
        public
        onlyAcctType("OPERATOR")
    {
        for (uint256 i = 0; i < _addr.length; i++) {
            if (whitelisted[_addr[i]]) {
                whitelisted[_addr[i]] = false;
                emit WhitelistStatusModified(_addr[i], false);
            }
        }
    }

    modifier isWhitelisted(address _addr) {
        require(
            whitelisted[_addr] || uint256(_addr) <= 65535,
            "Address is not whitelisted"
        );
        _;
    }

    event WhitelistStatusModified(address indexed _addr, bool);
}

// File: contracts/Mintable.sol

pragma solidity 0.5.16;


contract Mintable is AccountTyped, ERC20 {
    address public mintHoldingAcct;
    MintRequest[] public mintRequests;
    mapping(bytes32 => uint256) public mintersIdMap;
    Minter[] public minters;
    struct Minter {
        uint16 id;
        bool exists;
        bytes32 name;
        uint256[] mintHistory;
        address[] accountHistory;
    }
    struct MintRequest {
        uint64 id;
        uint16 minterId;
        bytes32 minterName;
        address approver;
        address receiver;
        bool active;
        bool approved;
        uint256 amount;
    }

    constructor(address _mintHoldingAcct) internal {
        Minter memory dummy;
        minters.push(dummy);
        mintHoldingAcct = _mintHoldingAcct;
        setAcctType(mintHoldingAcct, getAcctTypeByName("HOLDING"));
    }

    /**
     * @notice Create Mint request of specified number of tokens to minter
     * @param _id id of target minter to send request to
     * @param _amount amount to be minted
     */
    function createMintRequest(uint16 _id, uint256 _amount)
        public
        onlyAcctType("ADMIN")
    {
        Minter storage targetMinter = minters[_id];
        require(targetMinter.exists, "Minter does not exist");
        targetMinter.mintHistory.push(mintRequests.length);
        MintRequest memory req = MintRequest({
            amount: _amount,
            id: uint64(mintRequests.length),
            minterId: targetMinter.id,
            minterName: targetMinter.name,
            approver: msg.sender,
            receiver: address(0),
            active: true,
            approved: false
        });
        mintRequests.push(req);
        emitChangeEvent(mintRequests[mintRequests.length - 1]);
    }

    /**
     * @notice Cancel previously created mint request
     * @param _id id of mint request to cancel
     */
    function cancelMintRequest(uint64 _id) public onlyAcctType("ADMIN") {
        require(mintRequests.length > _id, "Request does not exist");
        require(mintRequests[_id].active, "Request was already concluded");
        mintRequests[_id].active = false;
        emitChangeEvent(mintRequests[_id]);
    }

    /**
     * @notice Approve previously created mint request
     * @param _id id of mint request to cancel
     */
    function approveMintRequest(uint64 _id) public {
        address approver = getAddressOfMinterById(mintRequests[_id].minterId);
        require(approver == msg.sender, "Request not found for approver");
        require(mintRequests.length > _id, "Request does not exist");
        require(mintRequests[_id].active, "Request was already concluded");
        _mint(mintHoldingAcct, mintRequests[_id].amount);
        mintRequests[_id].approved = true;
        mintRequests[_id].active = false; //kian: bug fix to mark status correctly as inactive
        mintRequests[_id].receiver = mintHoldingAcct;
        emitChangeEvent(mintRequests[_id]);
    }

    function getAddressOfMinter(Minter storage _minter)
        internal
        view
        returns (address)
    {
        require(
            _minter.accountHistory.length > 0,
            "Minter/Redeemer has no address"
        );
        return _minter.accountHistory[_minter.accountHistory.length - 1];
    }

    function getAddressOfMinterById(uint16 _id) public view returns (address) {
        return getAddressOfMinter(minters[_id]);
    }

    /**
     * @notice Reject previously created mint request
     * @param _id id of mint request to cancel
     */
    function rejectMintRequest(uint64 _id) public {
        address approver = getAddressOfMinterById(mintRequests[_id].minterId);
        require(approver == msg.sender, "Request not found for approver");
        require(mintRequests.length > _id, "Request does not exist");
        require(mintRequests[_id].active, "Request was already concluded");
        mintRequests[_id].approved = false;
        mintRequests[_id].active = false;
        emitChangeEvent(mintRequests[_id]);
    }

    /**
     * @dev Emit event for any change in request
     * @param _req the target request to be logged
     */
    function emitChangeEvent(MintRequest storage _req) private {
        emit MintRequestChanged(
            _req.id,
            _req.minterId,
            _req.active,
            _req.minterName,
            _req.approver,
            _req.receiver,
            _req.approved,
            _req.amount
        );
    }

    /**
     * @notice Add minter
     * @param _name name of minter
     * @param _address address of minter
     */
    function addMinter(string memory _name, address _address)
        public
        onlyAcctType("ADMIN")
    {
        require(
            mintersIdMap[stringToBytes32(_name)] == 0,
            "Minter must not exist"
        );
        uint16 id = uint16(minters.length);
        bytes32 byteName = stringToBytes32(_name);
        Minter memory minter;
        minter.exists = true;
        minter.name = byteName;
        minter.id = id;
        mintersIdMap[byteName] = id;
        minters.push(minter);
        minters[id].accountHistory.push(_address);
        setAcctType(_address, getAcctTypeByName("MINTER"));
        setAcctType(address(id), getAcctTypeByName("BURN"));
        emit MinterCreated(byteName, _address);
    }

    /**
     * @dev Change minter address, base on id
     * @param _id id of minter
     * @param _address new address of minter
     */
    function changeMinterAddress(uint16 _id, address _address)
        public
        onlyAcctType("ADMIN")
    {
        // only admin or self serve?
        Minter storage minter = minters[_id];
        address oldAddr = getAddressOfMinterById(minter.id);
        require(minter.exists, "Minter must exist");
        emit MinterChanged(minter.id, oldAddr, _address, minter.name);
        setAcctType(oldAddr, getAcctTypeByName("USER"));
        minter.accountHistory.push(_address);
        setAcctType(_address, getAcctTypeByName("MINTER"));
    }

    /**
     * @notice Update mint holding account address
     * Only Role: ADMIN
     * @param _holding new holding account address
     */
    function setMintHoldingAccount(address _holding)
        public
        onlyAcctType("ADMIN")
    {
        setAcctType(mintHoldingAcct, getAcctTypeByName("USER"));
        mintHoldingAcct = _holding;
        setAcctType(_holding, getAcctTypeByName("HOLDING"));
    }

    event MintRequestChanged(
        // indexed can be changed if filter needed on _approved etc
        uint64 indexed _id,
        uint16 indexed _minterId,
        bool indexed _active,
        bytes32 _minterName,
        address _approver,
        address _receiver,
        bool _approved,
        uint256 _amount
    );

    event MinterCreated(bytes32 indexed _name, address indexed _address);

    event MinterChanged(
        uint16 indexed _id,
        address indexed _oldAddress,
        address indexed _newAddress,
        bytes32 _name
    );
}

// File: contracts/Redeemable.sol

pragma solidity 0.5.16;



contract Redeemable is AccountTyped, Whitelistable, Mintable {
    RedeemRequest[] public redeemRequests;
    struct RedeemRequest {
        uint64 id;
        uint16 redeemerId;
        bytes32 redeemerName;
        address requester;
        bool active;
        bool approved;
        uint256 amount;
    }

    /**
     * @notice Create Redeem request of specified number of tokens to merchant
     * @param _id The id of target merchant to send request to
     * @param _amount The amounts to be redeemed
     */
    function createRedeemRequest(
        uint16 _id,
        address _requester,
        uint256 _amount
    ) internal isWhitelisted(_requester) {
        RedeemRequest memory req = RedeemRequest({
            amount: _amount,
            id: uint64(redeemRequests.length),
            requester: _requester,
            redeemerId: _id,
            redeemerName: minters[_id].name,
            active: true,
            approved: false
        });
        redeemRequests.push(req);
        emitChangeEvent(redeemRequests[redeemRequests.length - 1]);
    }

    /**
     * @notice Cancel previously created redeem request
     * @param _id id of redeem request to cancel
     */
    function cancelRedeemRequest(uint64 _id) public isWhitelisted(msg.sender) {
        require(redeemRequests.length > _id, "Request does not exist");
        require(
            redeemRequests[_id].requester == msg.sender,
            "Request doesn't belong to sender"
        );
        require(redeemRequests[_id].active, "Request was already concluded");
        redeemRequests[_id].active = false;
        _transfer(
            address(redeemRequests[_id].redeemerId),
            redeemRequests[_id].requester,
            redeemRequests[_id].amount
        );
        emitChangeEvent(redeemRequests[_id]);
    }

    /**
     * @notice Approve previously created redeem request
     * @param _id id of redeem request to cancel
     */
    function approveRedeemRequest(uint64 _id) public {
        require(redeemRequests.length > _id, "Request does not exist");
        require(
            getAddressOfMinterById(redeemRequests[_id].redeemerId) ==
                msg.sender,
            "Request doesn't target sender"
        );
        require(redeemRequests[_id].active, "Request was already concluded");
        redeemRequests[_id].approved = true;
        redeemRequests[_id].active = false;
        _burn(
            address(redeemRequests[_id].redeemerId),
            redeemRequests[_id].amount
        );
        emitChangeEvent(redeemRequests[_id]);
    }

    /**
     * @notice Reject previously created redeem request
     * @param _id id of redeem request to cancel
     */
    function rejectRedeemRequest(uint64 _id) public {
        require(redeemRequests.length > _id, "Request does not exist");
        require(
            getAddressOfMinterById(redeemRequests[_id].redeemerId) ==
                msg.sender,
            "Request doesn't target sender"
        );
        require(redeemRequests[_id].active, "Request was already concluded");
        redeemRequests[_id].approved = false;
        redeemRequests[_id].active = false;
        _transfer(
            address(redeemRequests[_id].redeemerId),
            redeemRequests[_id].requester,
            redeemRequests[_id].amount
        );
        emitChangeEvent(redeemRequests[_id]);
    }

    /**
     * @notice Emit event for any change in request
     * @param _req the target request to be logged
     */
    function emitChangeEvent(RedeemRequest storage _req) private {
        emit RedeemRequestChanged(
            _req.id,
            _req.redeemerId,
            _req.requester,
            _req.redeemerName,
            _req.approved,
            _req.active,
            _req.amount
        );
    }

    event RedeemRequestChanged(
        uint64 indexed _id,
        uint16 indexed _redeemerId,
        address indexed _requester,
        bytes32 _redeemerName,
        bool _approved,
        bool _active,
        uint256 _amount
    );
}

// File: contracts/Chargable.sol

pragma solidity 0.5.16;

/**
 * @title Provides methods related to fee (transaction and holding) management
 * @author Jayson Cheng
 */

contract Chargable is AccountTyped {
    mapping(address => uint256) public lastCollection;

    // fees read and stored as x * 10^(FEE_DECIMALS)
    // e.g. for 5% fee (i.e. 0.05), read and stored: 5 * 10^6 = 5000000;
    uint256 constant FEE_DECIMALS = 6;
    uint256 private feeDecimalMultiplier = 10**FEE_DECIMALS;
    address public feeHoldingAccount;
    address public txnFeeHoldingAccount; //kian added
    uint256 constant THAI_TIMEZONE_OFFSET = 28800;

    constructor(address _holdingAcct, address _txnHoldingAcc) public {
        feeHoldingAccount = _holdingAcct;
        setAcctType(feeHoldingAccount, getAcctTypeByName("HOLDING"));
        txnFeeHoldingAccount = _txnHoldingAcc;
        setAcctType(txnFeeHoldingAccount, getAcctTypeByName("HOLDING"));
    }

    /**
     * @notice Update holding account address
     * Only Role: ADMIN
     * @param _holding new holding account address
     */
    function setFeeHoldingAccount(address _holding)
        public
        onlyAcctType("ADMIN")
    {
        setAcctType(feeHoldingAccount, getAcctTypeByName("USER"));
        feeHoldingAccount = _holding;
        setAcctType(_holding, getAcctTypeByName("HOLDING"));
    }

    /**
     * @notice Update txn-fee holding account address
     * Only Role: ADMIN
     * @param _txnholding new holding account address
     */
    function setTxnFeeHoldingAccount(address _txnholding)
        public
        onlyAcctType("ADMIN")
    {
        setAcctType(txnFeeHoldingAccount, getAcctTypeByName("USER"));
        txnFeeHoldingAccount = _txnholding;
        setAcctType(_txnholding, getAcctTypeByName("HOLDING"));
    }


    /**
     * @notice Get annual holding fee rate (6 decimal) of _target address
     * @param _target target address
     */
    function getHoldingFeeRate(address _target) public view returns (uint256) {
        return getAcctTypeByAddr(_target).holdingFee;
    }

    /**
     * @notice Compute transaction fee given transaction amount, sender and receiver
     * @param _from sender address
     * @param _to receiver address
     * @param _amount transaction amount
     * @param _minimum minimum transaction amount if rate is not 0
     */
    function getTxnFee(
        address _from,
        address _to,
        uint256 _amount,
        uint256 _minimum
    ) public view returns (uint256) {
        uint256 feeRate = getRateByAddress(_from, _to);
        if (feeRate == 0) {
            return 0;
        }
        uint256 txnFee = (feeRate * _amount) / feeDecimalMultiplier;
        if (txnFee == 0) {
            txnFee = _minimum;
        }
        return txnFee;
    }

    /**
     * @notice Compute holding fee owned by target address since last collection, given balance amount
     * 1/365 of holding fee is acurred every day at 00:00 Thailand time (GMT+7)
     * @param _target target address
     * @param _balance balance amount
     */
    function holdingFeeOwedOnBalance(address _target, uint256 _balance) public view returns (uint256 fees) {
        if (lastCollection[_target] != 0) {
            // received or sent a transfer
            uint256 paidDays = (lastCollection[_target] +
                THAI_TIMEZONE_OFFSET) / 1 days;
            uint256 unpaidDays = (block.timestamp -
                (paidDays * 1 days) +
                THAI_TIMEZONE_OFFSET) / 1 days;

            return
                ((getHoldingFeeRate(_target) * _balance) * unpaidDays) /
                365 /
                feeDecimalMultiplier;
        }
    }
}

// File: contracts/GoldToken.sol

pragma solidity 0.5.16;

contract GoldToken is ERC20, ERC20Detailed, Pausable, Redeemable, Chargable {
    using SafeMath for uint256;

    constructor(address _feeHoldingAcct, address _txnFeeHoldingAcct, address _mintHoldingAcct, address _root)
        public
        ERC20Detailed("GoldGo", "GOGO", 18)
        //AccountTyped(msg.sender) //todo recover this
        AccountTyped(_root)
        Chargable(_feeHoldingAcct, _txnFeeHoldingAcct)
        Mintable(_mintHoldingAcct)
    {
        // empty
    }

    /**
     * @notice Transfer any ERC20 token belonging to this contract to caller
     * Only Role: ROOT
     * @param _tokenAddress The target ERC20 token address
     * @param _tokens The amount of tokens to be transferred
     */
    function transferAnyERC20Token(address _tokenAddress, uint256 _tokens)
        public
        onlyAcctType("ADMIN")
    {
        ERC20(_tokenAddress).transfer(msg.sender, _tokens);
    }

    /**
     * @notice Override ERC20 `transfer` method to check for whitelist, pause and burn logic
     */
    function transfer(address _to, uint256 _value)
        public
        whenNotPaused
        isWhitelisted(msg.sender)
        isWhitelisted(_to)
        returns (bool success)
    {
        // TODO: use BURN index instead of name?
        uint256 sendingAmount = _value.sub(collectTxnFee(msg.sender, _to, _value));
        if (getAcctTypeByAddr(_to).name == stringToBytes32("BURN")) {
            createRedeemRequest(minters[uint256(_to)].id, msg.sender, sendingAmount);
        }
        collectHoldingFee(msg.sender);
        collectHoldingFee(_to);

        
        return super.transfer(_to, sendingAmount);
    }

    /**
     * @notice Override ERC20 `transferFrom` method to check for whitelist, pause and burn logic
     */
    function transferFrom(address _from, address _to, uint256 _value)
        public
        whenNotPaused
        isWhitelisted(_from)
        isWhitelisted(_to)
        returns (bool)
    {
        // TODO: use BURN index instead of name?
        uint256 sendingAmount = _value.sub(collectTxnFee(_from, _to, _value));
        if (getAcctTypeByAddr(_to).name == stringToBytes32("BURN")) {
            createRedeemRequest(minters[uint256(_to)].id, _from, sendingAmount);
        }
        collectHoldingFee(_from);
        collectHoldingFee(_to);

        return super.transferFrom(_from, _to, sendingAmount);
    }

    function collectTxnFee(address _from, address _to, uint256 _amount)
        private
        returns (uint256 txnFees)
    {
        txnFees = getTxnFee(_from, _to, _amount, 1);
        if (txnFees != 0) {
            _transfer(_from, txnFeeHoldingAccount, txnFees);
        }
        emit CollectTxnFee(_from, txnFees);
    }

    /**
     * @notice Collect owed holding fee since last collection from target address
     * @param _from the target address
     */
    function collectHoldingFee(address _from) public {
        uint256 holdingFees = holdingFeeOwedOnBalance(_from, balanceOf(_from));
        if (holdingFees != 0) {
            _transfer(_from, feeHoldingAccount, holdingFees);
        }
        lastCollection[_from] = block.timestamp;
        emit CollectHoldingFee(_from,holdingFees);
    }

    /**
     * @notice Override ERC20 `approve` method to check for whitelist and pause
     */
    function approve(address spender, uint256 value)
        public
        whenNotPaused
        isWhitelisted(msg.sender)
        returns (bool)
    {
        return super.approve(spender, value);
    }

    /**
     * @notice Override ERC20 `increaseAllowance` method to check for whitelist and pause
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        whenNotPaused
        isWhitelisted(msg.sender)
        returns (bool success)
    {
        return super.increaseAllowance(spender, addedValue);
    }

    /**
     * @notice Override ERC20 `decreaseAllowance` method to check for whitelist and pause
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        whenNotPaused
        isWhitelisted(msg.sender)
        returns (bool success)
    {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    /**
     * @dev Emit event for any collection of fees
     * @param _txnFeesAsSender the account and amount of fees collected
     */
    event CollectTxnFee(address indexed _senderAdddress, uint256 _txnFeesAsSender );

    event CollectHoldingFee(address indexed _adddress,uint256 _holdingFee);

}
