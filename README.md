# Ethereum2022 Credential Status Type

## Abstract
This document introduces a new VerifiableCredential status type as defined in the Verifiable Credential data model. The approach for tracking the status of a Verifiable Credential is using an Ethereum smart contract on any network known and accessible by the verifier.

## Status of this Document
This specification is an unofficial draft. It is provided as a reference for people and organisations who wish to implement Ethereum-based proofs.

## Introduction
The Verifiable Credentials specification [describes](https://w3c.github.io/vc-data-model/#status) a modular mechanism for discovering the current status of a Verifiable Credential (VC).

This specification introduces a method based on Ethereum smart contracts, whereby the status of a VC is tracked by the state of the `id` attribute (inside the `credentialStatus` object) in a smart contract.

The choice of Ethereum blockchain as the tracking technique provides security on the current status of a VC, availability of the information, and enough flexibility to define any logic for updating the status. It is an efficient replacement for the approach of Certificate Revocation Lists, because using a distributed ledger removes the need for defining and authenticating trusted third parties.

## Specification

An `Ethereum2022` credential status is represented by an object contained in the `credentialStatus` attribute of a Verifiable Credential (VC).

It must contain the following attributes:

<dl>
    <dt>type</dt>
    <dd>The credential status type, as defined in the Verifiable Credential data model. The value MUST be <code>"Ethereum2022"</code>.</dd>
    <dt>id</dt>
    <dd>The status identifier, as defined in the VC data model.</dd>
    <dt>namespace</dt>
    <dd>A namespace for that identifier. The combination of identifier and namespace will be used for retrieving the status of the VC from the smart contract, following the documented ABI (see below).</dd>
    <dt>contractAddress</dt>
    <dd>A string containing the hexadecimal Ethereum address of the smart contract that tracks the status of the credential. For example: <code>"0x123f681646d4a755815f9cb19e1acc8565a0c2ac"</code>. That contract must implement **EIP-XXX (to be defined): Credential Status Registry**.</dd>
    <dt>networkId</dt>
    <dd>A string containing the hexadecimal NetworkId of the Ethereum network where the contract is deployed. In order to be able to verify the status, the verifier must have read access to a node running on that network and trust that that network represents the networkId meant by the issuer.</dd>
</dl>

### Example

```json
{
  "@type": "VerifiableCredential",
  "@context": "http://schema.org",
  "credentialSubject": {
    "@id": "did:example:abcd",
    "name": "John Doe",
    "birthdate": "2018-01-01"
  },
  "issuer": "did:example:efgh",
  "proof": {
    "type": "Example",
    "foo": "bar"
  },
  "credentialStatus": {
    "type": "Ethereum2022",
    "id": "12345",
    "namespace": "0x12435345",
    "contractAddress": "0x5E434DeF3E284a15Ad498c576cA746627ecAf806",
    "networkId": "0x7e4"
  }
}
```

### Solidity ABI

This method defines one function used to retrieve the status of a Verifiable Credential. The funcion takes the namespace and the id hash as arguments, and returns the status. Both inputs as well as the output are of type `bytes32`.

The `idHash` attribute is created by generating a SHA256 hash of the `id` URI present in the credential.

```solidity
function status(bytes32 namespace, bytes32 idHash) external view returns (bytes32);
```

### Possible status values

This document only specifies a basic set of credential status values. However, it is expected that some cases will require that basic set to be expanded with values that both issuers and verifiers understand.

| Value        | Name       | Description
|--------------|------------|---------------
| 0x0          | Current    | The credential is valid.
| 0x1          | Revoked    | The credential was revoked permanently.
| 0x2          | Suspended  | The credential was suspended temporarily.

Note that the credential status must only be checked if the credential can be verified using its proof. The status is irrelevant for VCs whose proof fails, because the content, including the `credentialStatus` attribute, may have been forged by an attacker.

## Notes

### Namespace semantics

The namespace is a symbolic attribute meant for classification of the IDs. Its semantics are not defined in this specification, and are instead left to the decision of the issuer.

### Updates to the smart contract

The interface only defines how to access the value, so how the value is to be updated depend on the implementation logic and on the requirements of the issuer.