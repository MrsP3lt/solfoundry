# Basic4626Deposit
[Git Source](https://github.com/MrsP3lt/solfoundry/blob/09ad585df6ec6c2a42c7a5c121c935d584701272/src/Basic4626Deposit.sol)


## State Variables
### asset

```solidity
address public immutable asset;
```


### name

```solidity
string public name;
```


### symbol

```solidity
string public symbol;
```


### decimals

```solidity
uint8 public immutable decimals;
```


### totalSupply

```solidity
uint256 public totalSupply;
```


### balanceOf

```solidity
mapping(address => uint256) public balanceOf;
```


## Functions
### constructor


```solidity
constructor(address asset_, string memory name_, string memory symbol_, uint8 decimals_);
```

### deposit


```solidity
function deposit(uint256 assets_, address receiver_) external returns (uint256 shares_);
```

### transfer


```solidity
function transfer(address recipient_, uint256 amount_) external returns (bool success_);
```

### convertToShares


```solidity
function convertToShares(uint256 assets_) public view returns (uint256 shares_);
```

### totalAssets


```solidity
function totalAssets() public view returns (uint256 assets_);
```

