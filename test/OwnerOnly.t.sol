// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";

error Unauthorized();

contract OwnerOnly {
    address public Owner;
    uint256 public count;

    constructor() {
        Owner = msg.sender;
    }

    function increment() public {
        if (msg.sender != Owner) {
            revert Unauthorized();
        }
        count++;
    }
}

contract TestOwnerOnly is Test {
    OwnerOnly public ownerOnly;

    function setUp() public {
        ownerOnly = new OwnerOnly();
    }

    function testIncrement() public {
        assertEq(ownerOnly.count(), 0);
        ownerOnly.increment();
        assertEq(ownerOnly.count(), 1);
    }

    function testIncrementAsNotOwner() public {
        vm.expectRevert(Unauthorized.selector);
        vm.prank(address(0));
        ownerOnly.increment();
    }
}
