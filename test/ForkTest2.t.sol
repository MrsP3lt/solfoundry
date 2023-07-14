// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "forge-std/Test.sol";

contract ForkTest2 is Test {
    // the identifiers of the forks
    uint256 mainnetFork;
    uint256 sepoliaFork;

    // create two _different_ forks during setup
    function setUp() public {
        mainnetFork = vm.createFork("mainnet");
        sepoliaFork = vm.createFork("optimism");
    }

    // creates a new contract while a fork is active
    function testFailCreateContract() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);

        // the new contract is written to `mainnetFork`'s storage
        SimpleStorageContract simple = new SimpleStorageContract();

        // and can be used as normal
        simple.set(100);
        assertEq(simple.value(), 100);

        // after switching to another contract we still know `address(simple)` but the contract only lives in `mainnetFork`
        vm.selectFork(sepoliaFork);

        /* this call will therefore revert because `simple` now points to a contract that does not exist on the active fork
         * it will produce following revert message:
         *
         * "Contract 0xCe71065D4017F316EC606Fe4422e11eB2c47c246 does not exist on active fork with id `1`
         *       But exists on non active forks: `[0]`"
         */
        simple.value();
    }

    // creates a new _persistent_ contract while a fork is active
    function testCreatePersistentContract() public {
        vm.selectFork(mainnetFork);
        SimpleStorageContract simple = new SimpleStorageContract();
        simple.set(100);
        assertEq(simple.value(), 100);

        // mark the contract as persistent so it is also available when other forks are active
        vm.makePersistent(address(simple));
        assert(vm.isPersistent(address(simple)));

        vm.selectFork(sepoliaFork);
        assert(vm.isPersistent(address(simple)));

        // This will succeed because the contract is now also available on the `sepoliaFork`
        assertEq(simple.value(), 100);
    }
}

contract SimpleStorageContract {
    uint256 public value;

    function set(uint256 _value) public {
        value = _value;
    }
}
