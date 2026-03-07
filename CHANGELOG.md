# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added

- Secret creation with configurable labels and annotations
- Automatic replication with optional CMEK encryption
- User-managed replication with per-region replica and CMEK configuration
- Secret version creation with enable/disable support
- Base64-encoded secret data decoding
- Rotation policy configuration with period and next rotation time
- Pub/Sub topic notification bindings for secret events
- TTL-based automatic secret deletion
- Timestamp-based secret expiration
- Version alias management for semantic version references
- Secret-level IAM member bindings with conditional access
- Input validation for project IDs and IAM roles
- Basic, advanced, and complete usage examples
