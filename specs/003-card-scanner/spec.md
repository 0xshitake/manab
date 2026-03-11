---
feature: "Card Scanner"
status: draft
tier: complex
created: 2026-03-10
depends_on: ["000", "001", "002"]
---

# 003 - Card Scanner

## Summary

Camera-based card recognition — the core differentiator. Build the perceptual hash index, integrate the full scan pipeline (detect → warp → crop art → hash → lookup), and provide session-based scanning with match confirmation UI.

## User Stories

### US-001: Scan a card and identify it (Priority: P0)

**As a** collector
**I want** to point my camera at a card and have the app identify it
**So that** I can quickly add cards without manual search

**Acceptance Criteria:**
- GIVEN the scanner screen WHEN I point at a card on white background THEN the card border is detected and highlighted
- GIVEN a detected card WHEN the pipeline runs THEN the best match is shown in a bottom sheet with card name, set, and image
- GIVEN a match WHEN I confirm THEN the card is added to the scan session
- GIVEN a wrong match WHEN I tap to cycle THEN alternative candidates are shown

### US-002: Batch scan a stack of cards (Priority: P0)

**As a** collector
**I want** to scan multiple cards in a session
**So that** I can digitize a stack of cards efficiently

**Acceptance Criteria:**
- GIVEN a scan session WHEN I scan multiple cards THEN each is added to the session list
- GIVEN the session WHEN I swipe up THEN I see a summary of all scanned cards
- GIVEN the session WHEN I tap commit THEN all cards are added to a selected binder

### US-003: Pick the correct edition for reprints (Priority: P1)

**As a** collector
**I want** to select the correct set/edition when a card has multiple printings
**So that** my collection accurately reflects what I own

**Acceptance Criteria:**
- GIVEN a card with multiple printings WHEN matched THEN the edition picker shows all matching sets
- GIVEN the edition picker WHEN I select a specific set THEN that edition is used for the entry

### US-004: Lock scanning to specific sets (Priority: P1)

**As a** collector
**I want** to restrict matches to specific sets
**So that** I can efficiently scan a booster box where all cards are from one set

**Acceptance Criteria:**
- GIVEN scanner settings WHEN I enable set locking THEN I can select one or more sets
- GIVEN set lock is active WHEN I scan THEN only cards from locked sets are matched
- GIVEN set lock WHEN I disable it THEN matching returns to all sets

### US-005: Quick mode for fast scanning (Priority: P2)

**As a** collector
**I want** an auto-confirm mode
**So that** I can scan rapidly without tapping confirm each time

**Acceptance Criteria:**
- GIVEN scanner settings WHEN I enable quick mode THEN the best match is auto-confirmed after a brief delay
- GIVEN quick mode WHEN a low-confidence match occurs THEN the app pauses for manual confirmation

## Tasks

- T3.1: Hash index build tool — `tool/build_card_db.dart`: download art crops → compute RGB PHash → pack into `CardHash` table
- T3.2: Ship pre-built hash index — bundled as SQLite asset (~30-50MB), loaded per game mode
- T3.3: Art region crop — fixed pixel rects per game (MTG 2015 frame default, Pokemon SV/SM default)
- T3.4: RGB perceptual hash computation — `cv.PHash.compute()` on cropped art region
- T3.5: Hamming distance lookup — SQLite query on `CardHash` table, top-N candidates, game mode + set-lock filters
- T3.6: Scanner screen — full-screen camera preview with card border overlay from Phase 0
- T3.7: Match confirmation UI — bottom sheet with best match, cycle alternatives, edition picker
- T3.8: Session management — scan batch → review all → commit to binder
- T3.9: Set locking UI — settings gear in scanner, select sets to restrict matches
- T3.10: Quick mode — auto-confirm best match with configurable delay

## Technical Notes

- Hash index: `CardHash` table with `cardId`, `game`, `phashValue` (64-bit), `setCode`
- Art crop coordinates: see Art Crop Reference in architecture spec
  - MTG 2015 frame (default): (23, 98, 626, 430) on 672×936 image
  - Pokemon SV/SM (default): (60, 100, 615, 382) on 734×1024 image
- Hamming distance threshold: start with ≤10 bits, tune empirically
- Hash index size: ~115k cards × 12 bytes ≈ 1.4 MB
- Full pipeline: detect → warp → crop → hash → lookup should complete in <200ms
- Build tool runs on dev machine, not on-device — see `tool/` directory in architecture spec

## Exit Criteria

Can scan a stack of cards on a white background and add them to a binder with >90% top-1 accuracy on clean scans.

## Out of Scope

- OCR fallback for failed hash matches (Phase 7)
- Foil detection heuristics (Phase 7)
- Full-art / borderless card handling (open question — see architecture spec)
- Price tracking integration (Phase 4)
- Audio feedback during scanning (Phase 5)
