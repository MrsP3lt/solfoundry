// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";

contract ForkTest is Test {
    // the identifiers of the forks
    uint256 mainnetFork;
    uint256 sepoliaFork;

    // create two _different_ forks during setup
    function setUp() public {
        mainnetFork = vm.createFork(("mainnet"));
        sepoliaFork = vm.createFork(("optimism"));
    }

    // demonstrate fork ids are unique
    function testForkIdDiffer() public view {
        assert(mainnetFork != sepoliaFork);
    }

    // select a specific fork
    function testCanSelectFork() public {
        // select the fork
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);

        // from here on data is fetched from the `mainnetFork` if the EVM requests it and written to the storage of `mainnetFork`
    }

    // manage multiple forks in the same test
    function testCanSwitchForks() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);

        vm.selectFork(sepoliaFork);
        assertEq(vm.activeFork(), sepoliaFork);
    }

    // forks can be created at all times
    function testCanCreateAndSelectForkInOneStep() public {
        // creates a new fork and also selects it
        uint256 anotherFork = vm.createSelectFork("mainnet");
        assertEq(vm.activeFork(), anotherFork);
    }

    // set `block.number` of a fork
    function testCanSetForkBlockNumber() public {
        vm.selectFork(mainnetFork);
        vm.rollFork(1_337_000);

        assertEq(block.number, 1_337_000);
    }
}
