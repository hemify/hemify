# Deployment Steps
- Deploy HemifyTreasury
- Deploy HemifyEscrow
- Deploy HemifyAuction
- Deploy HemifySwap
- Deploy HemifyWager

-> HemifyTreasury.
  - allow() HemifyAuction.
  - allow() HemifySwap.
  - allow() HemifyWager.

-> HemifyEscrow.
  - allow() HemifyAuction.
  - allow() HemifySwap.
  - allow() HemifyWager.

# Independent (Deploy First)
- HemifyControl
- HemifyExchange