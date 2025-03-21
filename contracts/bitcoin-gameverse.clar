;; Title: Bitcoin GameVerse - Decentralized Gaming Protocol on Stacks
;;
;; Summary:
;; A revolutionary gaming protocol built on Stacks that leverages Bitcoin's security
;; and value proposition. It enables true ownership of in-game assets, transparent
;; reward distribution, and seamless integration with Bitcoin's ecosystem.
;;
;; Description:
;; Bitcoin GameVerse implements a comprehensive gaming infrastructure that brings
;; Bitcoin's principles to gaming:
;; - Proof-of-ownership for game assets using NFTs
;; - Bitcoin-backed reward system for player achievements
;; - Decentralized trading system with STX settlements
;; - Secure player progression system with verifiable achievements
;; - Multi-world gaming ecosystem with granular access control
;; - Rate-limited operations to prevent gaming the system
;; - Battle-tested security measures protecting player assets

;; Constants
(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-INVALID-GAME-ASSET (err u2))
(define-constant ERR-INSUFFICIENT-FUNDS (err u3))
(define-constant ERR-TRANSFER-FAILED (err u4))
(define-constant ERR-LEADERBOARD-FULL (err u5))
(define-constant ERR-ALREADY-REGISTERED (err u6))
(define-constant ERR-INVALID-REWARD (err u7))
(define-constant ERR-INVALID-INPUT (err u8))
(define-constant ERR-INVALID-SCORE (err u9))
(define-constant ERR-INVALID-FEE (err u10))
(define-constant ERR-INVALID-ENTRIES (err u11))
(define-constant ERR-PLAYER-NOT-FOUND (err u12))
(define-constant ERR-INVALID-AVATAR (err u13))
(define-constant ERR-WORLD-NOT-FOUND (err u14))
(define-constant ERR-INVALID-NAME (err u15))
(define-constant ERR-INVALID-DESCRIPTION (err u16))
(define-constant ERR-INVALID-RARITY (err u17))
(define-constant ERR-INVALID-POWER-LEVEL (err u18))
(define-constant ERR-INVALID-ATTRIBUTES (err u19))
(define-constant ERR-INVALID-WORLD-ACCESS (err u20))
(define-constant ERR-INVALID-OWNER (err u21))
(define-constant ERR-MAX-LEVEL-REACHED (err u22))
(define-constant ERR-MAX-EXPERIENCE-REACHED (err u23))
(define-constant ERR-INVALID-LEVEL-UP (err u24))
(define-constant ERR-TRADE-NOT-FOUND (err u25))
(define-constant ERR-TRADE-EXPIRED (err u26))
(define-constant ERR-INVALID-TRADE-STATUS (err u27))
(define-constant ERR-INSUFFICIENT-BALANCE (err u28))

;; Constants for game mechanics
(define-constant MAX-LEVEL u100)
(define-constant MAX-EXPERIENCE-PER-LEVEL u1000)
(define-constant BASE-EXPERIENCE-REQUIRED u100)
(define-constant RATE-LIMIT-WINDOW u144)  ;; 24 hours in blocks
(define-constant MAX-CALLS-PER-WINDOW u100)

;; Event Types
(define-constant EVENT-ASSET-MINTED "asset-minted")
(define-constant EVENT-ASSET-TRANSFERRED "asset-transferred")
(define-constant EVENT-AVATAR-CREATED "avatar-created")
(define-constant EVENT-EXPERIENCE-GAINED "experience-gained")
(define-constant EVENT-LEVEL-UP "level-up")
(define-constant EVENT-WORLD-CREATED "world-created")
(define-constant EVENT-TRADE-INITIATED "trade-initiated")
(define-constant EVENT-TRADE-COMPLETED "trade-completed")
(define-constant EVENT-TRADE-CANCELLED "trade-cancelled")

;; Protocol Configuration
(define-data-var protocol-fee uint u10)
(define-data-var max-leaderboard-entries uint u50)
(define-data-var total-prize-pool uint u0)
(define-data-var total-assets uint u0)
(define-data-var total-avatars uint u0)
(define-data-var total-worlds uint u0)
(define-data-var total-trades uint u0)
;; Protocol Administrator Whitelist
(define-map protocol-admin-whitelist principal bool)

;; Input Validation Functions
(define-private (is-valid-name (name (string-ascii 50)))
  (and 
    (>= (len name) u1)
    (<= (len name) u50)
    (not (is-eq name ""))
  )
)

(define-private (is-valid-description (description (string-ascii 200)))
  (and 
    (>= (len description) u1)
    (<= (len description) u200)
    (not (is-eq description ""))
  )
)

(define-private (is-valid-rarity (rarity (string-ascii 20)))
  (or 
    (is-eq rarity "common")
    (is-eq rarity "uncommon")
    (is-eq rarity "rare")
    (is-eq rarity "epic")
    (is-eq rarity "legendary")
  )
)

(define-private (is-valid-power-level (power uint))
  (and (>= power u1) (<= power u1000))
)

(define-private (is-valid-attributes (attributes (list 10 (string-ascii 20))))
  (and 
    (>= (len attributes) u1)
    (<= (len attributes) u10)
  )
)

(define-private (is-valid-world-access (worlds (list 10 uint)))
  (and 
    (>= (len worlds) u1)
    (<= (len worlds) u10)
    (fold check-world-exists worlds true)
  )
)

(define-private (check-world-exists (world-id uint) (valid bool))
  (and valid (is-some (get-world-details world-id)))
)

;; NFT Definitions
(define-non-fungible-token gameverse-asset uint)
(define-non-fungible-token player-avatar uint)

;; Asset Metadata Map
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

;; Player Avatar Map
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

;; Game Worlds
(define-map game-worlds
  { world-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 200),
    entry-requirement: uint,
    active-players: uint,
    total-rewards: uint
  }
)

;; Leaderboard System
(define-map leaderboard 
  { player: principal }
  { 
    score: uint, 
    games-played: uint,
    total-rewards: uint,
    avatar-id: uint,
    rank: uint,
    achievements: (list 20 (string-ascii 50))
  }
)

;; Leaderboard System
(define-map player-rankings
  { rank: uint }
  { player: principal, score: uint }
)

;; Trade System
(define-map active-trades
  { trade-id: uint }
  {
    seller: principal,
    asset-id: uint,
    price: uint,
    expiry: uint,
    status: (string-ascii 20),
    buyer: (optional principal)
  }
)

;; Security Enhancement: Rate Limiting
(define-map rate-limits
  { function: (string-ascii 50), caller: principal }
  { last-call: uint, calls: uint }
)


;; Utility Functions
(define-read-only (is-protocol-admin (sender principal))
  (default-to false (map-get? protocol-admin-whitelist sender))
)

(define-read-only (is-valid-principal (input principal))
  (and 
    (not (is-eq input tx-sender))
    (not (is-eq input (as-contract tx-sender)))
  )
)

(define-read-only (is-safe-principal (input principal))
  (and 
    (is-valid-principal input)
    (or 
      (is-protocol-admin input)
      (is-some (map-get? leaderboard { player: input }))
    )
  )
)

(define-read-only (get-world-details (world-id uint))
  (map-get? game-worlds { world-id: world-id })
)

(define-read-only (get-avatar-details (avatar-id uint))
  (map-get? avatar-metadata { avatar-id: avatar-id })
)