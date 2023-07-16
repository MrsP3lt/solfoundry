# NFT
[Git Source](https://github.com/MrsP3lt/solfoundry/blob/09ad585df6ec6c2a42c7a5c121c935d584701272/src/NFT.sol)

**Inherits:**
ERC721, Ownable


## State Variables
### baseURI

```solidity
string public baseURI;
```


### currentTokenId

```solidity
uint256 public currentTokenId;
```


### TOTAL_SUPPLY

```solidity
uint256 public constant TOTAL_SUPPLY = 10_000;
```


### MINT_PRICE

```solidity
uint256 public constant MINT_PRICE = 0.08 ether;
```


## Functions
### constructor


```solidity
constructor(string memory _name, string memory _symbol, string memory _baseURI) ERC721(_name, _symbol);
```

### mintTo


```solidity
function mintTo(address recipient) public payable returns (uint256);
```

### tokenURI


```solidity
function tokenURI(uint256 tokenId) public view virtual override returns (string memory);
```

### withdrawPayments


```solidity
function withdrawPayments(address payable payee) external onlyOwner;
```

