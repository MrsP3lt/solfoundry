// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "forge-std/Test.sol";

contract A {
    uint256 public number;
    bool public boolian;

    constructor(uint256 _number) {
        number = _number;
    }
}

contract ForgeStdTest is Test {
    uint256[] public data = [10, 20, 30, 40, 50];
    A public a;

    function setUp() public {
        a = new A(1);
    }

    function test_EmitingItems_InArray() public {
        emit log_array(data);
        emit log_named_array("users", data);
    }

    function testFail_FailCheatCodeInUse() public {
        uint256 var1 = a.number();
        if (var1 == 1) {
            fail("The function has failed");
        }
    }

    function test_UseOfAssertFalse() public {
        assertFalse(a.boolian());
    }

    function test_UseofAssertEq() public {
        assertEq(a.number(), 1);
    }

    function test_UseOfAssertApproxEqAbs() external {
        uint256 a1 = 100;
        uint256 b2 = 200;
        // assertApproxEqAbs(a1, b2, 90); Fails
        assertApproxEqAbs(a1, b2, 110);
    }

    function test_UseOfAssertApproxEqRel() external {
        uint256 a1 = 100;
        uint256 b2 = 200;
        // assertApproxEqRel(a1, b2, 0.4e18); Fails
        assertApproxEqRel(a1, b2, 0.5e18);
    }

    function test_UseOfBlockTimeStamp() external {
        assertEq(block.timestamp, 1);
        skip(3600);
        assertEq(block.timestamp, 3601);
        rewind(3600);
        assertEq(block.timestamp, 1);
    }

    function test_UseOfConsoleLog() external view {
        console2.log(address(this).balance);
    }

    function test_UseOfHoax() public {
        hoax(address(10), 200);
        assertEq(address(10).balance, 200);
    }

    function test_UseOfStartHoax() external {
        startHoax(address(10), 200);
    }
}
