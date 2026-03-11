# Tasks: Collection Management

**Input**: Design documents from `/specs/002-collection-management/`
**Prerequisites**: plan.md (required), spec.md (required), 001-card-database completed

---

## Phase 1: Data Layer

**Goal**: Add Binder and CardEntry tables to the Drift database with DAOs.

- [ ] T001 Create `lib/domain/binder.dart` with `Binder` model: id (UUID), name, game (GameMode), createdAt, updatedAt (`lib/domain/binder.dart`)
- [ ] T002 Create `lib/domain/card_entry.dart` with `CardEntry` model: id (UUID), binderId, game, cardId, name, setCode, setName, collectorNumber, quantity, foil, language, condition (nullable), purchasePrice (nullable), purchaseCurrency (nullable), notes (nullable), imageUrl, addedAt, updatedAt (`lib/domain/card_entry.dart`)
- [ ] T003 Create `lib/data/database/tables/binders_table.dart` with Drift table, index on `game` column (`lib/data/database/tables/binders_table.dart`)
- [ ] T004 [P] Create `lib/data/database/tables/card_entries_table.dart` with Drift table, indexes on `(binderId)` and `(cardId)` (`lib/data/database/tables/card_entries_table.dart`)
- [ ] T005 Create `lib/data/database/migrations/migration_v1_to_v2.dart`: add `binders` and `card_entries` tables, preserve existing `cached_cards` data (`lib/data/database/migrations/migration_v1_to_v2.dart`)
- [ ] T006 Update `lib/data/database/app_database.dart`: register new tables, bump schema version to 2, wire migration (`lib/data/database/app_database.dart`)
- [ ] T007 Create `lib/data/database/daos/binders_dao.dart`: `watchAll(game)` → `Stream<List<Binder>>`, `create(name, game)`, `rename(id, name)`, `delete(id)`, `getById(id)` (`lib/data/database/daos/binders_dao.dart`)
- [ ] T008 Create `lib/data/database/daos/card_entries_dao.dart`: `watchByBinder(binderId)`, `addCard(entry)`, `updateCard(entry)`, `removeCard(id)`, `getByCardId(cardId)` (returns all binders containing card), `countByBinder(binderId)`, `totalValueByBinder(binderId)` (`lib/data/database/daos/card_entries_dao.dart`)

---

## Phase 2: Repository + Export

**Goal**: Create binder repository and JSON export service.

- [ ] T009 Create `lib/data/repositories/binder_repository.dart` with abstract interface + impl: wraps BindersDao + CardEntriesDao, methods: `watchBinders(game)`, `createBinder(name)`, `renameBinder(id, name)`, `deleteBinder(id)`, `addCardToBinder(binderId, card, metadata)`, `updateEntry(entry)`, `removeEntry(id)`, `watchBinderEntries(binderId)` (`lib/data/repositories/binder_repository.dart`)
- [ ] T010 Create `lib/data/services/export_service.dart`: `exportToJson(binders)` → generates JSON matching architecture spec export format, returns file path (`lib/data/services/export_service.dart`)

---

## Phase 3: Home Screen (Binder List)

**Goal**: Build the collection home screen with binder list.

- [ ] T011 Create `lib/ui/collection/collection_view_model.dart`: Riverpod notifier, watches binders for active game mode via `BinderRepository.watchBinders`, computes per-binder card count + value (`lib/ui/collection/collection_view_model.dart`)
- [ ] T012 Create `lib/ui/collection/collection_screen.dart`: list of binders, FAB to create new binder, long-press for rename/delete context menu (`lib/ui/collection/collection_screen.dart`)
- [ ] T013 Create `lib/ui/collection/widgets/binder_list_tile.dart`: binder name, card count, total value, tap to navigate to detail (`lib/ui/collection/widgets/binder_list_tile.dart`)
- [ ] T014 Create `lib/ui/collection/widgets/binder_create_dialog.dart`: text input for binder name, create button (`lib/ui/collection/widgets/binder_create_dialog.dart`)

---

## Phase 4: Binder Detail Screen

**Goal**: Build the binder contents view with sorting and filtering.

- [ ] T015 Create `lib/ui/collection/binder_detail_screen.dart`: card list with header showing binder name + total value, sort options (name, set, price, date added), search/filter within binder (`lib/ui/collection/binder_detail_screen.dart`)
- [ ] T016 Create `lib/ui/collection/widgets/card_entry_tile.dart`: card thumbnail, name, set, quantity, price, foil indicator, tap to navigate to card detail (`lib/ui/collection/widgets/card_entry_tile.dart`)

---

## Phase 5: Add Card to Binder Flow

**Goal**: Enable adding cards to binders from the card detail screen.

- [ ] T017 Create `lib/ui/collection/widgets/add_to_binder_sheet.dart`: bottom sheet with binder picker, quantity spinner, language dropdown, foil toggle, condition picker (NM/LP/MP/HP/DMG), purchase price input, notes field (`lib/ui/collection/widgets/add_to_binder_sheet.dart`)
- [ ] T018 Update `lib/ui/card_browser/card_detail_screen.dart`: add "Add to binder" FAB, show which binders already contain this card with link to edit entry (`lib/ui/card_browser/card_detail_screen.dart`)

---

## Phase 6: Export + Settings

**Goal**: Wire up JSON export and update navigation.

- [ ] T019 Update `lib/ui/settings/settings_screen.dart`: add "Export collection (JSON)" option that triggers `ExportService.exportToJson`, share via system share sheet (`lib/ui/settings/settings_screen.dart`)
- [ ] T020 Update `lib/config/router.dart`: add routes for collection screen (home), binder detail, update navigation to make collection the default home screen (`lib/config/router.dart`)

---

## Phase 7: Verification

**Goal**: Confirm collection management works end-to-end.

- [ ] T021 Test binder CRUD: create 3 binders → rename one → delete one → verify list updates reactively
- [ ] T022 Test add card: search → card detail → add to binder with quantity=4, foil=true, condition=LP → verify in binder detail
- [ ] T023 Test binder detail sorting: add 10 cards → sort by name, set, price, date → verify correct ordering
- [ ] T024 Test collection value: add cards with known prices → verify per-binder and total values are correct
- [ ] T025 Test JSON export: export → inspect JSON → verify structure matches spec, all cards and metadata present
- [ ] T026 Test game mode: create binders in MTG mode → switch to Pokemon → verify MTG binders hidden, create Pokemon binder → switch back → verify both sets exist
- [ ] T027 Test DB migration: install old version (schema v1) → update to new version → verify card data preserved, new tables created
