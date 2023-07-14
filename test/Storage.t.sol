// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

contract Storage {
    uint256[] public data;

    mapping(address => uint256) public balances;

    uint256 public value;

    function push(uint256 x) public {
        data.push(x);
    }

    function getData(uint256 _slot, uint256 index) public view returns (uint256) {
        uint256 slot = uint256(keccak256(abi.encodePacked(_slot))) + index;
        assembly {
            let a := sload(slot)
            mstore(0, a)
            return(0, 32)
        }
    }
}

contract TestStorage is Test {
    Storage public store;

    function setUp() public {
        store = new Storage();
    }

    function testGetData() public {
        store.push(1);
        store.push(2);
        console.log(store.getData(0, 1));
        assertEq(store.getData(0, 1), 2);
    }
}
