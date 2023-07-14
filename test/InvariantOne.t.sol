// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {InvariantOne} from "../src/InvariantOne.sol";

contract InvariantExample1 is Test {
    InvariantOne foo;

    function setUp() external {
        foo = new InvariantOne();
    }

    function invariant_A() external {
        assertEq(foo.val1() + foo.val2(), foo.val3());
    }

    function invariant_B() external {
        assertGe(foo.val1() + foo.val2(), foo.val1());
    }
}
