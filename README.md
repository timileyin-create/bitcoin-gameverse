# Bitcoin GameVerse Protocol Documentation

## Overview

Bitcoin GameVerse is a revolutionary decentralized gaming protocol built on Stacks that integrates directly with Bitcoin's security model. The protocol enables true digital ownership of in-game assets, transparent reward systems, and a player-centric gaming economy powered by blockchain technology.

## Key Features

- Bitcoin-secured NFT assets
- Cross-game avatar system
- Multi-world gaming ecosystem
- Transparent leaderboard with BTC rewards
- Decentralized asset marketplace
- Player progression with verifiable achievements
- Protocol-level rate limiting
- Battle-tested security model

## Technical Specifications

### Protocol Constants

```clarity
(define-constant MAX-LEVEL u100)
(define-constant MAX-EXPERIENCE-PER-LEVEL u1000)
(define-constant RATE-LIMIT-WINDOW u144)  // 24 hours in blocks
```

### Core Data Structures

**Game Asset NFT:**

```clarity
(define-map gameverse-asset-metadata
  { token-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 200),
    rarity: (string-ascii 20),
    power-level: uint,
    world-id: uint,
    attributes: (list 10 (string-ascii 20)),
    experience: uint,
    level: uint
  }
)
```

**Player Avatar:**

```clarity
(define-map avatar-metadata
  { avatar-id: uint }
  {
    name: (string-ascii 50),
    level: uint,
    experience: uint,
    achievements: (list 20 (string-ascii 50)),
    equipped-assets: (list 5 uint),
    world-access: (list 10 uint)
  }
)
```

## Core Functionality

### 1. Asset Management

**Minting New Game Assets:**

```clarity
(mint-gameverse-asset
  "Dragon Sword"
  "Legendary weapon of ancient kings"
  "legendary"
  u950
  u1
  (list "fire" "magic")
)
```

- Requires protocol admin privileges
- Enforces strict metadata validation
- Mints NFT with attached game properties

**Asset Transfer Flow:**

1. Ownership verification
2. Recipient validation
3. NFT transfer execution
4. Event emission

### 2. Player Progression System

**Avatar Creation:**

```clarity
(create-avatar
  "Warrior123"
  (list u1 u2 u3)
)
```

- Creates NFT-based player identity
- Sets initial world access permissions
- Initializes leaderboard entry

**Experience System:**

```clarity
(update-avatar-experience u123 u250)
```

- Validates admin privileges
- Checks level cap constraints
- Calculates experience thresholds
- Handles level-up transitions

### 3. Decentralized Marketplace

**Trade Creation:**

```clarity
(create-trade u456 u50000000 u20145)
// Lists asset #456 for 50 STX until block 20145
```

**Trade Execution:**

1. Balance verification
2. STX payment processing
3. NFT ownership transfer
4. Trade status update

### 4. Leaderboard & Rewards

**Scoring Mechanism:**

```clarity
(update-player-score 'SP123456 u1500)
```

- Admin-controlled score updates
- Anti-cheat protections
- Dynamic reward calculations

**Reward Distribution:**

- Top player identification
- STX reward calculations
- Transparent payout process
- Leaderboard state updates

## Security Features

### Access Control

```clarity
(define-map protocol-admin-whitelist principal bool)
```

- Multi-sig capable admin system
- Granular function-level permissions
- Principal validation checks

### Rate Limiting

```clarity
(define-map rate-limits
  { function: (string-ascii 50), caller: principal }
  { last-call: uint, calls: uint }
)
```

- Per-function call tracking
- Sliding window enforcement
- Anti-spam protections

### Asset Protection

- NFT ownership verification
- Trade expiration system
- Atomic swap transactions
- STX payment escrow

## Event System

| Event Type                | Description                        |
| ------------------------- | ---------------------------------- |
| `EVENT-ASSET-MINTED`      | New game asset creation            |
| `EVENT-ASSET-TRANSFERRED` | Ownership change of NFT items      |
| `EVENT-LEVEL-UP`          | Player avatar progression update   |
| `EVENT-TRADE-COMPLETED`   | Successful marketplace transaction |

## Error Codes

| Code                   | Description                      |
| ---------------------- | -------------------------------- |
| ERR-NOT-AUTHORIZED     | Unauthorized access attempt      |
| ERR-INVALID-GAME-ASSET | Nonexistent asset reference      |
| ERR-TRADE-EXPIRED      | Attempt to execute expired trade |
| ERR-MAX-LEVEL-REACHED  | Player level cap enforcement     |
