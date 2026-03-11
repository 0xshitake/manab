# Tasks: Verification + Testing

**Input**: Design documents from `/specs/006-verification-testing/`
**Prerequisites**: plan.md (required), spec.md (required), all previous phases (000-005) completed

---

## Phase 1: Test Infrastructure

**Goal**: Set up shared test utilities, fakes, and fixtures.

- [ ] T001 Create `testing/fakes/fake_cards_dao.dart`: in-memory fake of CardsDao for unit testing (`testing/fakes/fake_cards_dao.dart`)
- [ ] T002 [P] Create `testing/fakes/fake_binders_dao.dart`: in-memory fake of BindersDao (`testing/fakes/fake_binders_dao.dart`)
- [ ] T003 [P] Create `testing/fakes/fake_api_service.dart`: mock Scryfall/TCGdex API with canned responses (`testing/fakes/fake_api_service.dart`)
- [ ] T004 Create `testing/fixtures/sample_cards.dart`: 20 sample CachedCard objects (10 MTG, 10 Pokemon) with realistic data (`testing/fixtures/sample_cards.dart`)
- [ ] T005 [P] Create `testing/fixtures/sample_binders.dart`: 3 sample binders with CardEntry objects (`testing/fixtures/sample_binders.dart`)
- [ ] T006 [P] Create `testing/fixtures/sample_csv.dart`: sample Manabox CSV string for import testing (`testing/fixtures/sample_csv.dart`)

---

## Phase 2: Unit Tests — Domain Models

**Goal**: Test data model serialization and business logic.

- [ ] T007 Create `test/domain/card_test.dart`: CachedCard JSON serialization/deserialization, field validation, equality (`test/domain/card_test.dart`)
- [ ] T008 [P] Create `test/domain/card_entry_test.dart`: CardEntry JSON round-trip, condition enum parsing, price calculation (quantity × price) (`test/domain/card_entry_test.dart`)
- [ ] T009 [P] Create `test/domain/binder_test.dart`: Binder JSON round-trip, game mode scoping (`test/domain/binder_test.dart`)

---

## Phase 3: Unit Tests — Data Layer

**Goal**: Test DAOs, repositories, and services.

- [ ] T010 Create `test/data/daos/cards_dao_test.dart`: searchByName returns correct results, game mode filtering, bulk insert (`test/data/daos/cards_dao_test.dart`)
- [ ] T011 [P] Create `test/data/daos/binders_dao_test.dart`: CRUD operations, watchAll reactivity, game scoping (`test/data/daos/binders_dao_test.dart`)
- [ ] T012 [P] Create `test/data/daos/card_entries_dao_test.dart`: add/remove/update, quantity handling, value calculation (sum of prices × quantities, foil vs regular) (`test/data/daos/card_entries_dao_test.dart`)
- [ ] T013 [P] Create `test/data/daos/card_hashes_dao_test.dart`: Hamming distance calculation correctness, game mode filtering, set lock filtering, top-N ranking (`test/data/daos/card_hashes_dao_test.dart`)
- [ ] T014 Create `test/data/services/export_service_test.dart`: JSON export structure matches spec, empty binder export produces valid JSON, all metadata fields present (`test/data/services/export_service_test.dart`)
- [ ] T015 [P] Create `test/data/services/import_service_test.dart`: CSV parsing correctness, card matching, error handling for malformed CSV (`test/data/services/import_service_test.dart`)
- [ ] T016 [P] Create `test/data/services/scanner_service_test.dart`: PHash determinism (same image → same hash), art crop dimensions correct per game mode (`test/data/services/scanner_service_test.dart`)
- [ ] T017 Create `test/data/repositories/binder_repository_test.dart`: addCardToBinder, updateEntry, removeEntry, value calculation (`test/data/repositories/binder_repository_test.dart`)

---

## Phase 4: Integration Tests

**Goal**: On-device tests for API clients, DB lifecycle, and round-trips.

- [ ] T018 Create `integration_test/api_client_test.dart`: Scryfall — fetch card by name, parse response, handle rate limit error; TCGdex — fetch card by ID, handle unavailable card (`integration_test/api_client_test.dart`)
- [ ] T019 Create `integration_test/db_lifecycle_test.dart`: fresh install → extract bundled DB → query cards → verify data integrity → simulate delta update → verify new data merged (`integration_test/db_lifecycle_test.dart`)
- [ ] T020 Create `integration_test/db_migration_test.dart`: create DB at schema v1 → run all migrations → verify tables exist and data preserved at latest schema (`integration_test/db_migration_test.dart`)
- [ ] T021 Create `integration_test/export_import_roundtrip_test.dart`: create binder with 10 cards → export JSON → clear DB → import JSON → verify binder + cards identical; repeat for CSV (`integration_test/export_import_roundtrip_test.dart`)

---

## Phase 5: Scanner Test Corpus

**Goal**: Build the photo corpus and automated accuracy test.

- [ ] T022 Photograph 50 MTG cards with Pixel 8a: 20 clean (white bg, good lighting), 15 angled (±15°), 10 glare/shadow, 5 foil/holo — save to `testing/corpus/mtg/` (`testing/corpus/mtg/`)
- [ ] T023 [P] Photograph 50 Pokemon cards with Pixel 8a: 20 clean, 15 angled, 10 glare/shadow, 5 foil — save to `testing/corpus/pokemon/` (`testing/corpus/pokemon/`)
- [ ] T024 Create `testing/corpus/manifest.json`: map each photo filename to expected cardId, game, setCode, category (clean/angled/glare/foil) (`testing/corpus/manifest.json`)
- [ ] T025 Create `integration_test/scanner_accuracy_test.dart`: load each corpus photo → run full pipeline (detect → warp → crop → hash → lookup) → compare result to manifest → compute detection rate, top-1 accuracy, top-3 accuracy, latency per category (`integration_test/scanner_accuracy_test.dart`)

---

## Phase 6: Edge Case Tests

**Goal**: Cover all specified edge cases.

- [ ] T026 Test: card not in DB → scanner returns "no match", UI shows manual search fallback (`test/` or `integration_test/`)
- [ ] T027 Test: duplicate scan in session → quantity increments to 2, single entry (`test/data/`)
- [ ] T028 Test: very low value card ($0.01) → identified, price displays "$0.01" not "$0.00" or blank (`test/ui/`)
- [ ] T029 Test: same artwork 5+ sets → edition picker shows all, correct set selectable (`test/data/`)
- [ ] T030 Test: empty binder JSON export → valid JSON with empty cards array (`test/data/services/`)
- [ ] T031 Test: network offline during price refresh → uses cached prices, shows "last updated" timestamp (`test/data/services/`)
- [ ] T032 Test: switch game mode mid-scan-session → scanner restarts, old session preserved/discarded (`test/ui/`)

---

## Phase 7: Performance Benchmarks

**Goal**: Measure and validate performance targets on target hardware.

- [ ] T033 Benchmark: app cold start time — target <3s on Pixel 8a (`integration_test/`)
- [ ] T034 Benchmark: card search latency — target <100ms for type-ahead results (`integration_test/`)
- [ ] T035 Benchmark: hash index load time — target <500ms per game (`integration_test/`)
- [ ] T036 Benchmark: scanner frame processing rate — target >15 fps for border detection (`integration_test/`)
- [ ] T037 Benchmark: memory usage with full hash index loaded — target <150MB RSS (`integration_test/`)
- [ ] T038 Benchmark: DB size after 1000 cards in collection — target <5MB user data (`integration_test/`)

---

## Phase 8: Manual QA

**Goal**: Complete the full manual QA checklist.

- [ ] T039 QA: Full walkthrough — install → search → create binder → add 10 cards → verify prices → export JSON → verify JSON
- [ ] T040 QA: Scanner walkthrough — scan 20 cards → review session → correct 2 misidentifications → commit → verify all added
- [ ] T041 QA: Game mode — switch MTG → Pokemon → verify binders/search/scanner all reflect correct game
- [ ] T042 QA: Price tracking — add cards → wait 24h → verify prices updated → check value chart
- [ ] T043 QA: Offline — airplane mode → browse collection → search cached cards → verify no crashes
- [ ] T044 QA: Import — Manabox CSV export → import → verify card count + total value matches
- [ ] T045 QA: Stress test — 500+ cards in one binder → scroll, search, sort → verify no jank or OOM

---

## Phase 9: Final Sign-off

**Goal**: All tests pass, no P0/P1 bugs.

- [ ] T046 Run `flutter test` — all unit tests pass
- [ ] T047 Run integration tests on Pixel 8a — all pass
- [ ] T048 Run scanner accuracy test — detection >95%, top-1 >90%, top-3 >95% on clean scans, latency <200ms
- [ ] T049 Verify all performance benchmarks meet targets
- [ ] T050 Verify all manual QA items checked off with no P0/P1 bugs open
- [ ] T051 Build final release APK (`flutter build apk --split-per-abi --release`) and install on both Pixel 8a and Pixel 10 Pro
