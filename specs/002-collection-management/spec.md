---
feature: "Collection Management"
status: draft
tier: complex
created: 2026-03-10
depends_on: ["001"]
---

# 002 - Collection Management

## Summary

Start tracking what you own. Add binder management, card entry tracking with metadata (quantity, language, foil, condition), collection value summaries, and JSON export.

## User Stories

### US-001: Create and manage binders (Priority: P0)

**As a** collector
**I want** to organize my cards into named binders
**So that** I can separate different parts of my collection

**Acceptance Criteria:**
- GIVEN the home screen WHEN I tap the FAB THEN I can create a new binder with a name
- GIVEN a binder WHEN I long-press THEN I can rename or delete it
- GIVEN the home screen WHEN I view my binders THEN each shows card count + total value
- GIVEN I'm in MTG mode WHEN I create a binder THEN it's tagged as MTG (and vice versa for Pokemon)

### US-002: Add cards to binder via search (Priority: P0)

**As a** collector
**I want** to add cards from search results to my binders
**So that** I can build my collection digitally

**Acceptance Criteria:**
- GIVEN a card detail screen WHEN I tap "Add to binder" THEN I can pick a binder and set quantity, language, foil status
- GIVEN a card already in a binder WHEN I view its detail THEN I see which binders contain it and can edit the entry

### US-003: Browse and sort binder contents (Priority: P0)

**As a** collector
**I want** to browse cards in a binder with sorting and filtering
**So that** I can find specific cards in my collection

**Acceptance Criteria:**
- GIVEN a binder detail view WHEN I view it THEN cards are listed with name, set, price, date added
- GIVEN the binder WHEN I sort THEN I can sort by name, set, price, or date added
- GIVEN the binder WHEN I search THEN I can filter by name within that binder
- GIVEN the binder WHEN I view the header THEN total collection value is displayed

### US-004: Track per-card metadata (Priority: P1)

**As a** collector
**I want** to track condition, purchase price, and notes per card
**So that** I have complete records of my collection

**Acceptance Criteria:**
- GIVEN adding a card WHEN I set metadata THEN I can specify: quantity, language, foil/non-foil, condition (NM/LP/MP/HP/DMG), purchase price, notes
- GIVEN a card entry WHEN I edit it THEN all metadata fields are editable

### US-005: Export collection to JSON (Priority: P1)

**As a** collector
**I want** to export my collection data
**So that** I can back it up or use it in other tools

**Acceptance Criteria:**
- GIVEN settings WHEN I tap export THEN the app generates a JSON file matching the export format spec
- GIVEN the export WHEN I inspect the JSON THEN it contains all binders, cards, and metadata

## Tasks

- T2.1: Drift tables — `Binder` and `CardEntry` tables with DAOs, migrations
- T2.2: Binder CRUD — create, rename, delete with confirmation
- T2.3: Home screen — binder list with card count + total value per binder
- T2.4: Add card to binder flow — from card detail, pick binder, set quantity/language/foil
- T2.5: Per-card metadata — condition, purchase price, currency, notes fields
- T2.6: Binder detail view — card list, sortable by name/set/price/date added
- T2.7: Filter within binder — search by name, filter by game
- T2.8: Collection value summary — per binder and total on home screen
- T2.9: JSON export — from settings, generates spec-compliant JSON
- T2.10: Card detail update — show "Add to binder" button, show which binders contain the card

## Technical Notes

- Data model: `Binder` and `CardEntry` as defined in architecture spec
- Binders are game-specific — created under the active game mode
- Collection value = sum of (price × quantity) for all cards, using regular or foil price as appropriate
- Reactive UI via Drift streams + Riverpod `StreamProvider`
- Export format: JSON as specified in architecture spec (binders → cards array with all metadata)

## Exit Criteria

Can manage a full collection manually, see total value, and export it as JSON.

## Out of Scope

- Camera-based card scanning (Phase 3)
- Price history / value over time (Phase 4)
- CSV import/export (Phase 5)
- Bulk edit operations (Phase 5)
- Wishlist (Phase 5)
