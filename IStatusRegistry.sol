// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IStatusRegistry {
  // This function returns the status of `id` inside `namespace`.
  // The interface only defines how to access the value, so the semantics
  // of the namespace and how the value is to be updated depend on the
  // implementation logic.
  function status(bytes32 namespace, bytes32 idHash) external view returns (bytes32);
}