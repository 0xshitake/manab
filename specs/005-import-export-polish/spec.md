---
feature: "Import/Export + Polish"
status: draft
tier: complex
created: 2026-03-10
depends_on: ["002", "003"]
---

# 005 - Import/Export + Polish

## Summary

Interoperability and daily-driver quality. Add CSV import/export (Manabox-compatible), bulk edit, collector mode, wishlist, audio feedback during scanning, and a full UI polish pass.

## User Stories

### US-001: Import from Manabox CSV (Priority: P0)

**As a** collector migrating from Manabox
**I want** to import my existing collection via CSV
**So that** I don't have to re-enter everything manually

**Acceptance Criteria:**
- GIVEN a Manabox CSV export WHEN I import it THEN all cards are created in appropriate binders
- GIVEN the import flow WHEN parsing THEN a preview shows what will be imported with any errors highlighted
- GIVEN import errors WHEN some cards can't be matched THEN a report shows which cards failed

### US-002: Export to Manabox-compatible CSV (Priority: P0)

**As a** collector
**I want** to export my collection as CSV
**So that** I can use it in Manabox or other tools

**Acceptance Criteria:**
- GIVEN settings WHEN I export to CSV THEN the format matches Manabox CSV structure
- GIVEN the export WHEN I import it in Manabox THEN cards are recognized correctly

### US-003: Bulk edit cards (Priority: P1)

**As a** collector
**I want** to edit multiple cards at once
**So that** I can quickly update language, condition, or foil status for a batch

**Acceptance Criteria:**
- GIVEN a binder WHEN I enter multi-select mode THEN I can select multiple cards
- GIVEN selected cards WHEN I tap bulk edit THEN I can change language, condition, or foil for all at once

### US-004: Track set completion (Priority: P1)

**As a** collector
**I want** to see which cards I own vs which I'm missing per set
**So that** I can work toward completing sets

**Acceptance Criteria:**
- GIVEN collector mode WHEN I view a set THEN a grid shows owned vs missing cards, grouped by rarity
- GIVEN the grid WHEN I tap a missing card THEN I can view its details

### US-005: Maintain a wishlist (Priority: P2)

**As a** collector
**I want** a separate wishlist
**So that** I can track cards I want to acquire

**Acceptance Criteria:**
- GIVEN any card WHEN I add to wishlist THEN it appears in a separate wishlist view
- GIVEN the wishlist WHEN I acquire a card THEN I can move it to a binder and remove from wishlist

### US-006: Audio feedback during scanning (Priority: P2)

**As a** collector scanning cards
**I want** to hear price-tier tones
**So that** I know a card's approximate value without looking at the screen

**Acceptance Criteria:**
- GIVEN scanning with audio enabled WHEN a card is identified THEN a tone plays based on price tier (<$1, $1-$10, >$10)

## Tasks

- T5.1: CSV import — parse Manabox CSV format, preview screen, error report
- T5.2: CSV export — generate Manabox-compatible CSV from collection
- T5.3: Import service — `import_service.dart` with format detection and card matching
- T5.4: Bulk edit — multi-select in binder view, batch update language/condition/foil
- T5.5: Collector mode — set completion grid, owned vs missing, grouped by set/rarity
- T5.6: Wishlist — separate list, add from any card, move to binder on acquisition
- T5.7: Audio feedback — `just_audio` integration, price tier tones during scanning
- T5.8: UI polish pass — animations, loading states, error handling, empty states throughout the app

## Technical Notes

- Manabox CSV format: need to reverse-engineer exact column names/format from a Manabox export
- Import matching: match cards by name + set code + collector number against local DB
- Audio: `just_audio` package, bundled tone assets for 3 price tiers
- Collector mode: query all cards in a set from `CachedCard`, cross-reference with `CardEntry` for ownership

## Exit Criteria

Can import a Manabox CSV export and see full collection with prices.

## Out of Scope

- Other import formats (Archidekt, Deckbox, etc.)
- Deck building features
- Trading/social features
- Cloud sync
