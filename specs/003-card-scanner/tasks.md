# Tasks: Card Scanner

**Input**: Design documents from `/specs/003-card-scanner/`
**Prerequisites**: plan.md (required), spec.md (required), 000-opencv-poc completed, 001-card-database completed, 002-collection-management completed

---

## Phase 1: Hash Index Data Layer

**Goal**: Add CardHash table and Hamming distance lookup to the database.

- [ ] T001 Create `lib/domain/card_hash.dart` with `CardHash` model: cardId, game, phashValue (64-bit int), setCode (`lib/domain/card_hash.dart`)
- [ ] T002 Create `lib/data/database/tables/card_hashes_table.dart` with Drift table, indexes on `(game)` and `(game, setCode)` (`lib/data/database/tables/card_hashes_table.dart`)
- [ ] T003 Create `lib/data/database/daos/card_hashes_dao.dart` with `findByHammingDistance(hash, game, {threshold: 10, setLock: null, limit: 5})` — loads hashes for active game, computes Hamming distance in Dart, returns top-N candidates sorted by distance (`lib/data/database/daos/card_hashes_dao.dart`)
- [ ] T004 Create `lib/data/database/migrations/migration_v2_to_v3.dart`: add `card_hashes` table (`lib/data/database/migrations/migration_v2_to_v3.dart`)
- [ ] T005 Update `lib/data/database/app_database.dart`: register `CardHashes` table, bump schema to v3, wire migration (`lib/data/database/app_database.dart`)

---

## Phase 2: Hash Build Tool

**Goal**: Extend the build tool to compute perceptual hashes for all card art crops.

- [ ] T006 Create `tool/phash_computer.dart`: load art crop image → `cv.PHash.compute()` → return 64-bit hash value. Batch processing with progress reporting and resume support (`tool/phash_computer.dart`)
- [ ] T007 Update `tool/build_card_db.dart`: after card data import, download art crop images → compute PHash → insert into `CardHash` table in output DB. Add `--hash-only` flag for rebuilding just hashes (`tool/build_card_db.dart`)
- [ ] T008 Run full hash build for at least 1 MTG set (~300 cards) and 1 Pokemon set (~200 cards) — verify hashes are deterministic (same image → same hash) (`tool/build_card_db.dart`)

---

## Phase 3: Scanner Pipeline Extension

**Goal**: Extend the scanner service with art crop, PHash computation, and index lookup.

- [ ] T009 Add art region crop to `lib/data/services/scanner_service.dart`: `cropArtRegion(Mat warped, GameMode game)` using fixed pixel rects — MTG: (23, 98, 626, 430), Pokemon: (60, 100, 615, 382) (`lib/data/services/scanner_service.dart`)
- [ ] T010 Add PHash computation: `computeHash(Mat artCrop)` using `cv.PHash.create()` + `hasher.compute()` → returns 64-bit hash (`lib/data/services/scanner_service.dart`)
- [ ] T011 Create `lib/data/repositories/scanner_repository.dart`: `identifyCard(hash, game, {setLock})` → queries CardHashesDao, joins with CachedCard for full card info, returns ranked candidates (`lib/data/repositories/scanner_repository.dart`)
- [ ] T012 Wire full pipeline in scanner service: detect → warp → crop art → hash → lookup → return candidates (`lib/data/services/scanner_service.dart`)

---

## Phase 4: Scanner UI

**Goal**: Build the scanner screen with match confirmation and session management.

- [ ] T013 Update `lib/ui/scanner/scanner_screen.dart`: full-screen camera preview, card border overlay (from Phase 0), bottom area for match confirmation, settings gear icon, session summary swipe-up (`lib/ui/scanner/scanner_screen.dart`)
- [ ] T014 Create `lib/ui/scanner/widgets/match_confirmation_sheet.dart`: bottom sheet showing best match card image + name + set + price, confirm button, reject button, "cycle" button to see next candidate (`lib/ui/scanner/widgets/match_confirmation_sheet.dart`)
- [ ] T015 Create `lib/ui/scanner/widgets/edition_picker.dart`: when card has multiple printings, show list of all matching editions with set name + set icon, tap to select (`lib/ui/scanner/widgets/edition_picker.dart`)
- [ ] T016 Update `lib/ui/scanner/scanner_view_model.dart`: manage scan session state — list of confirmed cards, current candidates, active set lock, quick mode toggle (`lib/ui/scanner/scanner_view_model.dart`)

---

## Phase 5: Session Management

**Goal**: Implement batch scan → review → commit workflow.

- [ ] T017 Create `lib/ui/scanner/widgets/scan_session_summary.dart`: scrollable list of all cards scanned in current session, quantity per card, edit/remove individual entries, total count + value (`lib/ui/scanner/widgets/scan_session_summary.dart`)
- [ ] T018 Add session commit: "Save to binder" button → binder picker → create CardEntry for each scanned card → write via BinderRepository (`lib/ui/scanner/scanner_view_model.dart`)
- [ ] T019 Handle duplicate scans: if same card scanned again in session, increment quantity instead of adding duplicate entry (`lib/ui/scanner/scanner_view_model.dart`)

---

## Phase 6: Set Lock + Quick Mode

**Goal**: Add scanner configuration options for power users.

- [ ] T020 Create `lib/ui/scanner/widgets/scanner_settings_sheet.dart`: set lock toggle + set picker (multi-select from available sets), quick mode toggle (`lib/ui/scanner/widgets/scanner_settings_sheet.dart`)
- [ ] T021 Implement set locking in scanner repository: when set lock active, filter hash lookup to only locked set codes (`lib/data/repositories/scanner_repository.dart`)
- [ ] T022 Implement quick mode in view model: auto-confirm best match after 1.5s delay if Hamming distance ≤ 5 (high confidence), pause for manual confirmation otherwise (`lib/ui/scanner/scanner_view_model.dart`)

---

## Phase 7: Verification

**Goal**: Confirm scanner works end-to-end with real cards.

- [ ] T023 Test single card scan: point at MTG card → verify detection → match shown → confirm → appears in session
- [ ] T024 Test batch scan: scan 10 cards → review session summary → commit to binder → verify all 10 in binder with correct names/sets
- [ ] T025 Test edition picker: scan a card with 5+ printings (e.g., Lightning Bolt) → verify all editions shown → select specific set → verify correct edition saved
- [ ] T026 Test set lock: enable set lock for one set → scan cards from that set + cards from other sets → verify only locked set cards match
- [ ] T027 Test duplicate handling: scan same card twice → verify quantity=2, not two entries
- [ ] T028 Test no match: scan a card not in the hash index → verify graceful "no match" message
- [ ] T029 Measure full pipeline latency: frame → detect → warp → crop → hash → lookup → display — target <200ms on Pixel 8a
