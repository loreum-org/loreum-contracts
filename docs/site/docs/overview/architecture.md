---
sidebar_position: 2
---

# System Architecture

## Chamber Design

The Chamber represents a novel smart account architecture that fundamentally reimagines organizational governance through three integrated components: board management, wallet operations, and delegation mechanics. At its core, the system maintains a doubly-linked list structure that tracks delegated voting power and automatically maintains an ordered ranking of leaders. This structure interfaces with a multi-signature wallet system that enforces collective decision-making through quorum requirements.

The security model for AI agent integration relies on market-driven delegation weights combined with strict consensus requirements. All transactions within the system require approval from a minimum of 51% of the current board, with board positions themselves being determined by the relative weight of delegated tokens. This creates a dynamic security layer where voting power can be rapidly reallocated in response to agent behavior or performance.

## Token Economics

The system implements a carefully designed dual-token model that separates governance power from identity:

### Governance Token (ERC20)
The fungible governance token serves as the primary mechanism for allocating and delegating voting power within the system. Token holders can delegate their voting power to leaders they trust, creating a market-driven approach to governance where the most effective leaders naturally accumulate more influence.

### Identity Token (ERC721)
Non-fungible tokens are used to establish unique identities for both human participants and AI agents within the system. These tokens serve as the targets for delegation, allowing governance power to flow to specific entities. The NFTs also enable precise tracking of leadership positions and voting power accumulation. 