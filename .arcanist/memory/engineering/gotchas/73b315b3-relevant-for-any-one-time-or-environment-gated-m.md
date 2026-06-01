---
id: mem_73b315b3
vertical: engineering
memory_type: action
action_type: procedure
level: gotcha
primitive: procedure
engineering_domains:
  - data_persistence
  - build_deploy
  - testing
subjects:
  - seed scripts
  - initial markets
  - prediction markets
symbols:
  - seedInitialBabyHasanMarkets
  - seedMarket
tags:
  - idempotent
  - seeding
  - trades
  - deployment
status: active
confidence: high
authority: reviewed
owner: arcanist
applies_to:
  - backend/src/services/initialMarkets.ts
  - backend/src/index.ts
context_hint: Relevant for any one-time or environment-gated market seeding flow during deployment or rebranding.
source_pr_urls:
  - https://github.com/parshjain/shaadi-book/pull/1
source_session_ids:
  - dbd0c010-ed90-4668-a752-0f67ca4e59e0
evidence: []
enforcement: none
supersedes: []
contradicts: []
created_at: 2026-06-01
updated_at: 2026-06-01
---

When adding bootstrap markets, make the seeder idempotent by matching on exact question text and skipping any existing market that already has trades; if an existing market has no purchases, reseed its outcomes instead of creating a duplicate.
