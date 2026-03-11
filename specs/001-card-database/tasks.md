# Tasks: Card Database + Search

**Input**: Design documents from `/specs/001-card-database/`
**Prerequisites**: plan.md (required), spec.md (required), 000-opencv-poc completed

---

## Phase 1: Database Layer

**Goal**: Set up Drift database with CachedCard table and DAOs.

- [ ] T001 Create `lib/domain/card.dart` with `CachedCard` domain model matching architecture spec fields: cardId, game, name, setCode, setName, collectorNumber, typeLine, rarity, imageUrl, artCropUrl, prices (USD/EUR, regular/foil), language, cachedAt (`lib/domain/card.dart`)
- [ ] T002 Create `lib/data/database/tables/cards_table.dart` with Drift `CachedCards` table definition matching `CachedCard` schema, proper column types, indexes on (game, name) and (game, setCode) (`lib/data/database/tables/cards_table.dart`)
- [ ] T003 Create `lib/data/database/app_database.dart` with `@DriftDatabase` annotation including `CachedCards` table, schema version 1 (`lib/data/database/app_database.dart`)
- [ ] T004 Create `lib/data/database/daos/cards_dao.dart` with methods: `searchByName(game, query)` returning `Stream<List<CachedCard>>`, `getById(cardId)`, `bulkInsert(cards)`, `getSetCodes(game)`, `getCardsBySet(setCode)` (`lib/data/database/daos/cards_dao.dart`)

---

## Phase 2: API Services

**Goal**: Implement Scryfall and TCGdex API clients for card data retrieval.

- [ ] T005 Create `lib/data/services/scryfall_api_service.dart` with `dio` client: Firefox UA header, 75ms request throttle, methods: `fetchBulkData()` (bulk JSON URL), `fetchCardByName(name)`, `fetchCardById(id)`, `fetchSetList()` (`lib/data/services/scryfall_api_service.dart`)
- [ ] T006 Create `lib/data/services/tcgdex_api_service.dart` with `dio` client: Firefox UA header, methods: `fetchCard(id)`, `fetchSetList()`, `fetchCardsBySet(setCode)`, support English + Spanish (`lib/data/services/tcgdex_api_service.dart`)
- [ ] T007 Create `lib/data/repositories/card_repository.dart` with abstract interface + implementation: `searchCards(game, query)`, `getCard(cardId)`, `refreshPrices(cardIds)`, `getAvailableSets(game)` — delegates to appropriate API service based on game mode (`lib/data/repositories/card_repository.dart`)

---

## Phase 3: Build Tool (Dev Machine)

**Goal**: Create the card DB build tool that generates the bundled SQLite asset.

- [ ] T008 Create `tool/scryfall_client.dart`: download Scryfall bulk data JSON, parse into card objects, handle pagination (`tool/scryfall_client.dart`)
- [ ] T009 [P] Create `tool/tcgdex_client.dart`: download all TCGdex cards (English + Spanish), parse into card objects (`tool/tcgdex_client.dart`)
- [ ] T010 Create `tool/db_packer.dart`: insert parsed cards into SQLite `CachedCards` table, create indexes, compress output (`tool/db_packer.dart`)
- [ ] T011 Create `tool/build_card_db.dart`: orchestrator script with `--full`, `--delta`, `--game=mtg|pokemon` flags — downloads data → packs into `assets/cards.db` (`tool/build_card_db.dart`)

---

## Phase 4: First Launch Flow

**Goal**: Implement game mode selection and bundled DB extraction.

- [ ] T012 Create `lib/data/services/db_extraction_service.dart`: extract compressed `assets/cards.db` to app documents directory, report progress via stream (`lib/data/services/db_extraction_service.dart`)
- [ ] T013 Create `lib/ui/core/widgets/game_mode_picker.dart`: full-screen picker with two large cards/buttons (MTG, Pokemon), stores selection in shared preferences (`lib/ui/core/widgets/game_mode_picker.dart`)
- [ ] T014 Create first launch flow in router: detect first launch → show game mode picker → extract DB with progress bar → navigate to card search screen (`lib/config/router.dart`)
- [ ] T015 Wire up Riverpod provider for game mode state — global toggle accessible from settings, persisted to shared preferences (`lib/config/di.dart`)

---

## Phase 5: Search + Card Detail UI

**Goal**: Build the card browsing screens.

- [ ] T016 Create `lib/ui/card_browser/card_browser_screen.dart`: search bar at top, results list below, scoped to active game mode (`lib/ui/card_browser/card_browser_screen.dart`)
- [ ] T017 Create `lib/ui/card_browser/card_browser_view_model.dart`: Riverpod notifier, debounced search (300ms), queries `CardsDao.searchByName` (`lib/ui/card_browser/card_browser_view_model.dart`)
- [ ] T018 Create `lib/ui/card_browser/widgets/card_list_tile.dart`: thumbnail (via `cached_network_image`), card name, set name, price (`lib/ui/card_browser/widgets/card_list_tile.dart`)
- [ ] T019 Create `lib/ui/card_browser/card_detail_screen.dart`: full card image, set, rarity, type line, prices (USD + EUR, regular + foil) (`lib/ui/card_browser/card_detail_screen.dart`)
- [ ] T020 Create `lib/ui/card_browser/widgets/price_display.dart`: formatted price widget showing regular + foil in USD + EUR (`lib/ui/card_browser/widgets/price_display.dart`)

---

## Phase 6: Set Image Download

**Goal**: Allow users to download card images per set for offline use.

- [ ] T021 Add image download method to card repository: `downloadSetImages(setCode)` — downloads all card images for a set to local app storage, reports progress (`lib/data/repositories/card_repository.dart`)
- [ ] T022 Create `lib/ui/settings/settings_screen.dart` with: game mode toggle, DB update trigger, navigate to downloaded sets manager (`lib/ui/settings/settings_screen.dart`)
- [ ] T023 Create `lib/ui/settings/widgets/downloaded_sets_manager.dart`: list of downloaded sets with name, card count, storage size, delete button (`lib/ui/settings/widgets/downloaded_sets_manager.dart`)

---

## Phase 7: DB Updates

**Goal**: Keep the card database current with new set releases.

- [ ] T024 Add delta update logic to `db_extraction_service.dart`: on app launch, check API for new sets since last update, download and merge new card data (`lib/data/services/db_extraction_service.dart`)
- [ ] T025 Add "last updated" timestamp display in settings, manual "Check for updates" button (`lib/ui/settings/settings_screen.dart`)

---

## Phase 8: Verification

**Goal**: Confirm card browsing works end-to-end.

- [ ] T026 Build bundled `cards.db` using build tool with at least one MTG set and one Pokemon set
- [ ] T027 Test first launch flow: game picker → DB extraction → land on search screen — verify on Pixel 8a
- [ ] T028 Test card search: type card name → verify results appear in <100ms with correct thumbnails and prices
- [ ] T029 Test card detail: tap card → verify full image, set, rarity, type, all 4 price fields display
- [ ] T030 Test set image download: pick a set → download → verify images available offline (airplane mode)
- [ ] T031 Test game mode switch: MTG → Pokemon → verify search results change, only Pokemon cards shown
