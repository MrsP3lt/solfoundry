# Forge standard library Challenges
1. Set block.timestamp
2. Set block.number 
3. Set block.basefee 
4. Set block.difficulty  
5. Set block.prevrandao
6. Set block.chainid
7. Loads a storage slot from an address
8. Stores a value to an address' storage slot
9. Signs data 
10. Computes address for a given private key
11. Derive a private key from a provided mnemonic string, or mnemonic file path, at the derivation path m44'60'0'0{index}.
12. Derive a private key from a provided mnemonic string, or mnemonic file path, at the derivation path {path}{index}
13. Gets the nonce of an account
14. Sets the nonce of an account: The new nonce must be higher than the current nonce of the account
15. Performs a foreign function call via terminal
16. Set environment variables, (name, value)
17. Read environment variables, (name) => (value)
18. Read environment variables as arrays, (name, delim) => (value[])
19. Read environment variables with default value, (name, value) => (value)
20. Read environment variables as arrays with default value, (name, value[]) => (value[])
21. Convert Solidity types to strings
22. Sets the *next* call's msg.sender to be the input address
23. Sets all subsequent calls' msg.sender to be the input address
24. Sets the *next* call's msg.sender to be the input address, and the tx.origin to be the second input
25. Sets all subsequent calls' msg.sender to be the input address until
26. `stopPrank` is called, and the tx.origin to be the second input
27. Resets subsequent calls' msg.sender to be `address(this)`
28. Reads the current `msg.sender` and `tx.origin` from state and reports if there is any active caller modification
29. Sets an address' balance
30. Set the balance of an account for any ERC20 token
31. Alternative signature to update `totalSupply`
32. Sets an address' code
33. Marks a test as skipped. Must be called at the top of the test.
34. Expects an error on next call
35. Record all storage reads and writes
36. Gets all accessed reads and write slot from a recording session, for a given address
37. Record all the transaction logs
38. Gets all the recorded logs
39. Prepare an expected log with the signature: (bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData).
40. Call this function, then emit an event, then call a function. Internally after the call, we check if logs were emitted in the expected order with the expected topics and data (as specified by the booleans)
41. Mocks a call to an address, returning specified data.
42. Calldata can either be strict or a partial match, e.g. if you only
43. Pass a Solidity selector to the expected calldata, then the entire Solidity function will be mocked.
44. Reverts a call to an address, returning the specified error Calldata can either be strict or a partial match, e.g. if you only
45. pass a Solidity selector to the expected calldata, then the entire Solidity function will be mocked.
46. Clears all mocked and reverted mocked calls
47. Expect a call to an address with the specified calldata.
48. Calldata can either be strict or a partial match
49. Expect a call to an address with the specified calldata and message value. Calldata can either be strict or a partial match
50. Gets the _creation_ bytecode from an artifact file. Takes in the relative path to the json file
51. Gets the _deployed_ bytecode from an artifact file. Takes in the relative path to the json file
52. Label an address in test traces
53. Retrieve the label of an address
54. When fuzzing, generate new inputs if conditional not met
55. Set block.coinbase (who)
56. Using the address that calls the test contract or the address provided as the sender, has the next call (at this call depth only) create a transaction that can later be signed and sent onchain
57. Using the address that calls the test contract or the address provided as the sender, has all subsequent calls (at this call depth only) create transactions that can later be signed and sent onchain
58. Stops collecting onchain transactions
59. Reads the entire content of file to string, (path) => (data)
60. Get the path of the current project root
61. Reads next line of file to string, (path) => (line)
62. Writes data to file, creating a file if it does not exist, and entirely replacing its contents if it does.
 (path, data) => ()
63. Writes line to file, creating a file if it does not exist. (path, data) => ()
64. Closes file for reading, resetting the offset and allowing to read it from beginning with readLine. (path) => ()
65. Removes file. This cheatcode will revert in the following situations, but is not limited to just these cases: - Path points to a directory. - The file doesn't exist. - The user lacks permissions to remove the file. (path) => ()
66. Return the value(s) that correspond to 'key'
67. Return the entire json file
68. Snapshot the current state of the evm.
69. Returns the id of the snapshot that was created.
70. To revert a snapshot use `revertTo`
71. Revert the state of the evm to a previous snapshot 
72. Takes the snapshot id to revert to.  
73. This deletes the snapshot and all snapshots taken after the given snapshot id.  
74. Creates a new fork with the given endpoint and block, and returns the identifier of the fork 
75. Creates a new fork with the given endpoint and the _latest_ block, and returns the identifier of the fork
76. Creates _and_ also selects a new fork with the given endpoint and block, and returns the identifier of the fork
77. Creates _and_ also selects a new fork with the given endpoint and the latest block and returns the identifier of the fork 
78. Takes a fork identifier created by `createFork` and sets the corresponding forked state as active.
79. Returns the currently active fork, Reverts if no fork is currently active
80. Updates the currently active fork to given block number
81. This is similar to `roll` but for the currently active fork
82. Updates the given fork to given block number
83. Fetches the given transaction from the active fork and executes it on the current state
84. Fetches the given transaction from the given fork and executes it on the current state
85. Marks that the account(s) should use persistent storage across
86. fork swaps in a multifork setup, meaning, changes made to the state of this account will be kept when switching forks 
87. Revokes persistent status from the address, previously added via `makePersistent` 
88. Returns true if the account is marked as persistent 
89. Returns the RPC url for the given alias 
90. Returns all rpc urls and their aliases `[alias, url][]`