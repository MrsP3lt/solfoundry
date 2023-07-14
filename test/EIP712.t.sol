// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import "forge-std/Test.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MOCK", 18) {}

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}

contract SigUtils {
    /// @notice The ERC-20 token domain separator
    bytes32 internal immutable DOMAIN_SEPARATOR;

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
    }

    /// @dev keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    struct Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }

    /// @dev Computes the hash of a permit
    /// @param _permit The approval to execute on-chain
    /// @return The encoded permit
    function getStructHash(Permit memory _permit) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(PERMIT_TYPEHASH, _permit.owner, _permit.spender, _permit.value, _permit.nonce, _permit.deadline)
        );
    }

    /// @notice Computes the hash of a fully encoded EIP-712 message for the domain
    /// @param _permit The approval to execute on-chain
    /// @return The digest to sign and use to recover the signer
    function getTypedDataHash(Permit memory _permit) public view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, getStructHash(_permit)));
    }
}
/// @title Deposit
/// @author kulkarohan
/// @notice Mock contract to transfer ERC-20 tokens with a signed approval

contract Deposit {
    ///                                                          ///
    ///                           EVENTS                         ///
    ///                                                          ///

    /// @notice Emitted after an ERC-20 token deposit
    /// @param user The depositooor
    /// @param tokenContract The token address
    /// @param amount The number of tokens deposited
    event TokenDeposit(address user, address tokenContract, uint256 amount);

    /// @notice Emitted after an ERC-20 token withdraw
    /// @param user The withdrawooor
    /// @param tokenContract The token address
    /// @param amount The number of tokens withdrawn
    event TokenWithdraw(address user, address tokenContract, uint256 amount);

    ///                                                          ///
    ///                           STORAGE                        ///
    ///                                                          ///

    /// @notice The number of tokens stored for a given user and token contract
    /// @dev User => ERC-20 address => Number of tokens deposited
    mapping(address => mapping(address => uint256)) public userDeposits;

    ///                                                          ///
    ///                           DEPOSIT                        ///
    ///                                                          ///

    /// @notice Deposits ERC-20 tokens (requires pre-approval)
    /// @param _tokenContract The ERC-20 token address
    /// @param _amount The number of tokens
    function deposit(address _tokenContract, uint256 _amount) external {
        ERC20(_tokenContract).transferFrom(msg.sender, address(this), _amount);

        userDeposits[msg.sender][_tokenContract] += _amount;

        emit TokenDeposit(msg.sender, _tokenContract, _amount);
    }

    ///                                                          ///
    ///                      DEPOSIT w/ PERMIT                   ///
    ///                                                          ///

    /// @notice Deposits ERC-20 tokens with a signed approval
    /// @param _tokenContract The ERC-20 token address
    /// @param _amount The number of tokens to transfer
    /// @param _owner The user signing the approval
    /// @param _spender The user to transfer the tokens (ie this contract)
    /// @param _value The number of tokens to appprove the spender
    /// @param _deadline The timestamp the permit expires
    /// @param _v The 129th byte and chain id of the signature
    /// @param _r The first 64 bytes of the signature
    /// @param _s Bytes 64-128 of the signature
    function depositWithPermit(
        address _tokenContract,
        uint256 _amount,
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        ERC20(_tokenContract).permit(_owner, _spender, _value, _deadline, _v, _r, _s);

        ERC20(_tokenContract).transferFrom(_owner, address(this), _amount);

        userDeposits[_owner][_tokenContract] += _amount;

        emit TokenDeposit(_owner, _tokenContract, _amount);
    }

    ///                                                          ///
    ///                           WITHDRAW                       ///
    ///                                                          ///

    /// @notice Withdraws deposited ERC-20 tokens
    /// @param _tokenContract The ERC-20 token address
    /// @param _amount The number of tokens
    function withdraw(address _tokenContract, uint256 _amount) external {
        require(_amount <= userDeposits[msg.sender][_tokenContract], "INVALID_WITHDRAW");

        userDeposits[msg.sender][_tokenContract] -= _amount;

        ERC20(_tokenContract).transfer(msg.sender, _amount);

        emit TokenWithdraw(msg.sender, _tokenContract, _amount);
    }
}

contract DepositTest is Test {
    ///                                                          ///
    ///                           SETUP                          ///
    ///                                                          ///

    Deposit internal deposit;
    MockERC20 internal token;
    SigUtils internal sigUtils;

    uint256 internal ownerPrivateKey;
    address internal owner;

    function setUp() public {
        deposit = new Deposit();
        token = new MockERC20();
        sigUtils = new SigUtils(token.DOMAIN_SEPARATOR());

        ownerPrivateKey = 0xA11CE;
        owner = vm.addr(ownerPrivateKey);

        token.mint(owner, 1e18);
    }

    ///                                                          ///
    ///                           DEPOSIT                        ///
    ///                                                          ///

    function test_Deposit() public {
        vm.prank(owner);
        token.approve(address(deposit), 1e18);

        vm.prank(owner);
        deposit.deposit(address(token), 1e18);

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(address(deposit)), 1e18);
        assertEq(deposit.userDeposits(owner, address(token)), 1e18);
    }

    function testFail_ContractNotApproved() public {
        vm.prank(owner);
        deposit.deposit(address(token), 1e18);
    }

    ///                                                          ///
    ///                       DEPOSIT w/ PERMIT                  ///
    ///                                                          ///

    function test_DepositWithLimitedPermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(deposit),
            value: 1e18,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        deposit.depositWithPermit(
            address(token), 1e18, permit.owner, permit.spender, permit.value, permit.deadline, v, r, s
        );

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(address(deposit)), 1e18);

        assertEq(token.allowance(owner, address(deposit)), 0);
        assertEq(token.nonces(owner), 1);

        assertEq(deposit.userDeposits(owner, address(token)), 1e18);
    }

    function test_DepositWithMaxPermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(deposit),
            value: type(uint256).max,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        deposit.depositWithPermit(
            address(token), 1e18, permit.owner, permit.spender, permit.value, permit.deadline, v, r, s
        );

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(address(deposit)), 1e18);

        assertEq(token.allowance(owner, address(deposit)), type(uint256).max);
        assertEq(token.nonces(owner), 1);

        assertEq(deposit.userDeposits(owner, address(token)), 1e18);
    }

    function testRevert_ExpiredPermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(deposit),
            value: 1e18,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        vm.warp(1 days + 1 seconds); // fast forwards one second past the deadline

        vm.expectRevert("PERMIT_DEADLINE_EXPIRED");
        deposit.depositWithPermit(
            address(token), 1e18, permit.owner, permit.spender, permit.value, permit.deadline, v, r, s
        );
    }

    function testRevert_InvalidSigner() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(deposit),
            value: 1e18,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0xB0B, digest); // 0xB0B signs but 0xA11CE is owner

        vm.expectRevert("INVALID_SIGNER");
        deposit.depositWithPermit(
            address(token), 1e18, permit.owner, permit.spender, permit.value, permit.deadline, v, r, s
        );
    }

    function testRevert_InvalidNonce() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(deposit),
            value: 1e18,
            nonce: 1, // set nonce to 1 instead of 0
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        vm.expectRevert("INVALID_SIGNER");
        deposit.depositWithPermit(
            address(token), 1e18, permit.owner, permit.spender, permit.value, permit.deadline, v, r, s
        );
    }

    function testFail_InvalidAllowance() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(deposit),
            value: 5e17, // sets allowance of 0.5 tokens
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        deposit.depositWithPermit(
            address(token), 1e18, permit.owner, permit.spender, permit.value, permit.deadline, v, r, s
        );
    }

    function testFail_InvalidBalance() public {
        SigUtils.Permit memory permit =
            SigUtils.Permit({owner: owner, spender: address(deposit), value: 2e18, nonce: 0, deadline: 1 days});

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        deposit.depositWithPermit(
            address(token),
            2e18, // owner was only minted 1 token
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );
    }

    ///                                                          ///
    ///                           WITHDRAW                       ///
    ///                                                          ///

    function test_Withdraw() public {
        vm.startPrank(owner);

        token.approve(address(deposit), 1e18);
        deposit.deposit(address(token), 1e18);

        deposit.withdraw(address(token), 5e17);

        vm.stopPrank();

        assertEq(token.balanceOf(owner), 5e17);
        assertEq(token.balanceOf(address(deposit)), 5e17);
    }

    function testRevert_InvalidWithdraw() public {
        vm.startPrank(owner);

        token.approve(address(deposit), 1e18);
        deposit.deposit(address(token), 1e18);

        vm.expectRevert("INVALID_WITHDRAW");
        deposit.withdraw(address(token), 2e18);

        vm.stopPrank();
    }
}

contract ERC20Test is Test {
    ///                                                          ///
    ///                           SETUP                          ///
    ///                                                          ///

    MockERC20 internal token;
    SigUtils internal sigUtils;

    uint256 internal ownerPrivateKey;
    uint256 internal spenderPrivateKey;

    address internal owner;
    address internal spender;

    function setUp() public {
        token = new MockERC20();
        sigUtils = new SigUtils(token.DOMAIN_SEPARATOR());

        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;

        owner = vm.addr(ownerPrivateKey);
        spender = vm.addr(spenderPrivateKey);

        token.mint(owner, 1e18);
    }

    ///                                                          ///
    ///                            PERMIT                        ///
    ///                                                          ///

    function test_Permit() public {
        SigUtils.Permit memory permit =
            SigUtils.Permit({owner: owner, spender: spender, value: 1e18, nonce: 0, deadline: 1 days});

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        assertEq(token.allowance(owner, spender), 1e18);
        assertEq(token.nonces(owner), 1);
    }

    function testRevert_ExpiredPermit() public {
        SigUtils.Permit memory permit =
            SigUtils.Permit({owner: owner, spender: spender, value: 1e18, nonce: token.nonces(owner), deadline: 1 days});

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        vm.warp(1 days + 1 seconds); // fast forward one second past the deadline

        vm.expectRevert("PERMIT_DEADLINE_EXPIRED");
        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);
    }

    function testRevert_InvalidSigner() public {
        SigUtils.Permit memory permit =
            SigUtils.Permit({owner: owner, spender: spender, value: 1e18, nonce: token.nonces(owner), deadline: 1 days});

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(spenderPrivateKey, digest); // spender signs owner's approval

        vm.expectRevert("INVALID_SIGNER");
        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);
    }

    function testRevert_InvalidNonce() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 1e18,
            nonce: 1, // owner nonce stored on-chain is 0
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        vm.expectRevert("INVALID_SIGNER");
        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);
    }

    function testRevert_SignatureReplay() public {
        SigUtils.Permit memory permit =
            SigUtils.Permit({owner: owner, spender: spender, value: 1e18, nonce: 0, deadline: 1 days});

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        vm.expectRevert("INVALID_SIGNER");
        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);
    }

    ///                                                          ///
    ///                         TRANSFER FROM                    ///
    ///                                                          ///

    function test_TransferFromLimitedPermit() public {
        SigUtils.Permit memory permit =
            SigUtils.Permit({owner: owner, spender: spender, value: 1e18, nonce: 0, deadline: 1 days});

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        vm.prank(spender);
        token.transferFrom(owner, spender, 1e18);

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(spender), 1e18);
        assertEq(token.allowance(owner, spender), 0);
    }

    function test_TransferFromMaxPermit() public {
        SigUtils.Permit memory permit =
            SigUtils.Permit({owner: owner, spender: spender, value: type(uint256).max, nonce: 0, deadline: 1 days});

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        vm.prank(spender);
        token.transferFrom(owner, spender, 1e18);

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(spender), 1e18);
        assertEq(token.allowance(owner, spender), type(uint256).max);
    }

    function testFail_InvalidAllowance() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 5e17, // approve only 0.5 tokens
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        vm.prank(spender);
        token.transferFrom(owner, spender, 1e18); // attempt to transfer 1 token
    }

    function testFail_InvalidBalance() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 2e18, // approve 2 tokens
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        vm.prank(spender);
        token.transferFrom(owner, spender, 2e18); // attempt to transfer 2 tokens (owner only owns 1)
    }
}
