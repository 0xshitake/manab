---
feature: "Card Database + Search"
status: draft
tier: complex
created: 2026-03-10
depends_on: ["000"]
---

# 001 - Card Database + Search

## Summary

Make the app useful for browsing cards and checking prices, even without a collection. Import card data from Scryfall (MTG) and TCGdex (Pokemon), store in local SQLite via Drift, and provide search and detail screens.

## User Stories

### US-001: First launch game mode selection (Priority: P0)

**As a** new user
**I want** to pick MTG or Pokemon on first launch
**So that** the app is configured for my game and ready to browse

**Acceptance Criteria:**
- GIVEN a fresh install WHEN the app opens THEN a full-screen game mode picker is shown (MTG or Pokemon)
- GIVEN I pick a game mode WHEN the DB is extracting THEN a progress bar shows extraction progress
- GIVEN extraction completes WHEN I land on the search screen THEN I can immediately browse cards

### US-002: Search cards by name (Priority: P0)

**As a** user
**I want** to search for cards by name
**So that** I can find any card and check its details

**Acceptance Criteria:**
- GIVEN the card search screen WHEN I type a card name THEN results appear as type-ahead (<100ms latency)
- GIVEN search results WHEN I see a card THEN it shows thumbnail, name, set, and price
- GIVEN search WHEN I search in MTG mode THEN only MTG cards appear (and vice versa for Pokemon)

### US-003: View card details with prices (Priority: P0)

**As a** user
**I want** to see full card details including current prices
**So that** I can check what a card is worth

**Acceptance Criteria:**
- GIVEN a search result WHEN I tap a card THEN the detail screen shows full image, set, rarity, type, prices (USD + EUR, regular + foil)
- GIVEN a card detail WHEN prices are available THEN both regular and foil prices display

### US-004: Download set images for offline use (Priority: P1)

**As a** user
**I want** to download all card images for specific sets
**So that** I can browse and later scan cards offline

**Acceptance Criteria:**
- GIVEN settings WHEN I pick sets to download THEN the app downloads all card images for those sets
- GIVEN downloaded sets WHEN I browse offline THEN card images display from local storage
- GIVEN settings WHEN I view downloaded sets THEN I see set names, storage used, and a delete option

### US-005: Database stays current (Priority: P2)

**As a** user
**I want** the card database to update when new sets release
**So that** I can always find the latest cards

**Acceptance Criteria:**
- GIVEN app launch WHEN new sets exist THEN the app downloads delta updates
- GIVEN an update WHEN it completes THEN new cards are searchable immediately

## Tasks

- T1.1: Drift database setup — `AppDatabase` with `CachedCard` table, migrations, DAOs
- T1.2: Scryfall bulk data import pipeline — download JSON → parse → insert into local DB
- T1.3: TCGdex API integration — download Pokemon cards (English + Spanish)
- T1.4: Build tool prototype — `tool/build_card_db.dart` to generate bundled `cards.db` asset
- T1.5: First launch flow — game mode picker → extract bundled DB → land on search
- T1.6: Card search screen — text search with type-ahead, scoped to active game mode
- T1.7: Card detail screen — full image, set, rarity, type, prices (USD + EUR, regular + foil)
- T1.8: Set-based image download — user picks sets → app downloads images to local storage
- T1.9: Downloaded sets manager — settings screen showing sets, storage used, delete option
- T1.10: DB delta update mechanism — check for new sets on app launch, download incremental data

## Technical Notes

- Data sources: Scryfall API (MTG) + TCGdex API (Pokemon) — see architecture spec for rate limits and usage terms
- Database: Drift with type-safe queries, reactive `Stream<List<T>>`, compile-time checked SQL
- Bundled DB: compressed SQLite asset (~15-20MB compressed, ~30-50MB extracted)
- Card metadata schema: `CachedCard` model in architecture spec
- API client: `dio` with interceptors for rate limiting
- User-Agent: Firefox UA string per API usage terms
- Image storage: app documents directory, organized by set code

## Exit Criteria

Can search any MTG or Pokemon card by name, see its current price, and download a set's images for offline use.

## Out of Scope

- Collection management / binders (Phase 2)
- Card scanning / recognition (Phase 3)
- Price history tracking (Phase 4)
- CSV import/export (Phase 5)
