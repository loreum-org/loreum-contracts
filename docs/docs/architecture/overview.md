---
sidebar_position: 1
---

# System Architecture

The Loreum system consists of three main architectural components:

## Board Management

The Board component implements a sophisticated doubly-linked list structure that:
- Maintains an ordered ranking of leaders based on delegated voting power
- Automatically reorders positions when delegation amounts change
- Tracks director status for the top N positions

## Wallet Operations

The Wallet component provides:
- Multi-signature transaction management
- Quorum-based approval system
- Batch transaction support
- Revocable transaction confirmations

## Delegation Mechanics

The delegation system enables:
- Market-driven leadership selection
- Fluid reallocation of voting power
- Double-entry bookkeeping for delegations
- Immediate withdrawal capabilities 