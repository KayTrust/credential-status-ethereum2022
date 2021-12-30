// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../IStatusRegistry.sol";

// In this implementation, the namespace of a tracked ID is understood as the address
// that can update its status.
// Note that the contract only tracks values. The meaning of each status value
// must be defined externally.
contract SenderStatusRegistry is IStatusRegistry {

  // Mapping: sender (used as namespace) => id => status
  mapping (address => mapping (bytes32 => bytes32)) private _status;

  // Get status by namespace and id.
  // Namespaces are 20-byte Ethereum addresses, so any larger value is refused to avoid mistakes,
  // then the bytes32 value is converted to an address.
  function status(bytes32 namespace, bytes32 idHash) public view returns (bytes32) {
    uint256 numNamespace = uint256(namespace);
    uint160 numNamespace20 = uint160(numNamespace);
    assert(numNamespace20 == numNamespace);
    return _status[address(numNamespace20)][idHash];
  }

  function updateStatus(bytes32 id, bytes32 value) public {
    _status[msg.sender][id] = value;
  }

}