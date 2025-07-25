# NurseCredentials - Digital Nursing License Verification

A decentralized system for managing and verifying nursing licenses on the Stacks blockchain.

## Features

- Register nursing credentials with license details
- Verify active licenses with expiration checking
- Track verification history
- License deactivation capabilities

## Contract Functions

### Public Functions
- `register-nurse`: Register a new nursing license
- `verify-credentials`: Verify and log credential verification
- `deactivate-license`: Deactivate a nursing license

### Read-Only Functions
- `get-nurse`: Retrieve nurse information by ID
- `is-license-valid`: Check if a license is currently valid

## Usage

Deploy the contract and use the owner account to register nurses. Healthcare employers can verify credentials using the `verify-credentials` function.

## Testing

Run tests with Clarinet:
```bash
clarinet test