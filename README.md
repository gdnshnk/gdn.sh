# gdn.sh : node[00]

Public verification node of the Proof of Human Work protocol.

## Node Information

- **Type**: Public Verification Node (Layer 4: Retrieval)
- **Status**: Active
- **Protocol Version**: v1.0.0-node00
- **Public Key**: [/.well-known/public.txt](/.well-known/public.txt)
- **Verification Endpoint**: [/pohw/verify](pohw/verify)

## Endpoints

- `GET /.well-known/public.txt` - Public key for signature verification
- `GET /pohw/verify/index.json` - Node status and metadata
- `GET /pohw/verify/index.cjson` - Canonical JSON for hashing
- `GET /pohw/verify/index.sig.bin` - Binary signature file
- `GET /pohw/verify/index.sig.b64` - Base64-encoded signature

## Protocol Reference

- Full Specification: https://proofofhumanwork.org/spec
- Registry: https://proofofhumanwork.org

## Node Purpose

This node serves as a minimal identity primitive for the PoHW protocol. It provides:
- Stateless verification endpoints
- Public key infrastructure
- Node status and attestation metadata
- Cryptographic proof of node identity

For complete documentation, see: https://proofofhumanwork.org
