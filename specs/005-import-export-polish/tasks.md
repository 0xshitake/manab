# Tasks: Import/Export + Polish

**Input**: Design documents from `/specs/005-import-export-polish/`
**Prerequisites**: plan.md (required), spec.md (required), 002-collection-management completed, 003-card-scanner completed

---

## Phase 1: CSV Import

**Goal**: Implement Manabox-compatible CSV import with preview and error handling.

- [ ] T001 Reverse-engineer Manabox CSV export format: export a collection from Manabox, document column names, types, and edge cases (`docs/manabox-csv-format.md`)
- [ ] T002 Add `csv` and `file_picker` dependencies to `pubspec.yaml` (`pubspec.yaml`)
- [ ] T003 Create `lib/data/services/import_service.dart`: `parseCsv(String path)` → parse CSV, match cards against local DB by name + set code + collector number, return list of matched/unmatched entries (`lib/data/services/import_service.dart`)
- [ ] T004 Create `lib/ui/settings/widgets/import_flow.dart`: file picker → parse → preview screen showing matched cards (green), unmatched cards (red), total count → confirm button → import to selected binder (`lib/ui/settings/widgets/import_flow.dart`)
- [ ] T005 Handle import edge cases: duplicate cards (merge quantities), unknown sets (skip with warning), missing fields (use defaults) (`lib/data/services/import_service.dart`)

---

## Phase 2: CSV Export

**Goal**: Export collection in Manabox-compatible CSV format.

- [ ] T006 Update `lib/data/services/export_service.dart`: add `exportToCsv(binders)` method generating Manabox-compatible CSV with correct column headers and format (`lib/data/services/export_service.dart`)
- [ ] T007 Update `lib/ui/settings/settings_screen.dart`: add "Export to CSV" option alongside existing JSON export, share via system share sheet (`lib/ui/settings/settings_screen.dart`)

---

## Phase 3: Bulk Edit

**Goal**: Enable multi-select and batch editing in binder detail view.

- [ ] T008 Add multi-select mode to `lib/ui/collection/binder_detail_screen.dart`: long-press to enter select mode, tap to toggle selection, select-all option, cancel button (`lib/ui/collection/binder_detail_screen.dart`)
- [ ] T009 Create `lib/ui/collection/widgets/bulk_edit_sheet.dart`: bottom sheet with fields: language dropdown, condition picker, foil toggle — only changed fields are applied to all selected cards (`lib/ui/collection/widgets/bulk_edit_sheet.dart`)
- [ ] T010 Wire bulk edit to repository: batch update selected CardEntry rows via `CardEntriesDao` (`lib/data/repositories/binder_repository.dart`)

---

## Phase 4: Collector Mode

**Goal**: Set completion tracking with visual grid.

- [ ] T011 Create `lib/ui/collection/widgets/set_completion_grid.dart`: grid of card thumbnails for a set, owned cards in full color, missing cards grayed out, grouped by rarity sections (Common, Uncommon, Rare, Mythic / Common, Uncommon, Holo Rare, etc.) (`lib/ui/collection/widgets/set_completion_grid.dart`)
- [ ] T012 Create `lib/ui/collection/collector_mode_screen.dart`: set picker at top → completion grid below, shows X/Y owned count per rarity and total, tap missing card to view detail (`lib/ui/collection/collector_mode_screen.dart`)
- [ ] T013 Update `lib/config/router.dart`: add route for collector mode, navigation from collection screen (`lib/config/router.dart`)

---

## Phase 5: Wishlist

**Goal**: Separate want-list for tracking desired cards.

- [ ] T014 Add wishlist storage: either new Drift table `Wishlist(cardId, game, addedAt, notes)` or reuse lightweight model — decide based on simplicity (`lib/data/database/`)
- [ ] T015 Create `lib/ui/collection/wishlist_screen.dart`: list of wished cards with name, set, price, "acquired" action (moves to binder) (`lib/ui/collection/wishlist_screen.dart`)
- [ ] T016 Update `lib/ui/card_browser/card_detail_screen.dart`: add "Add to wishlist" option alongside "Add to binder" (`lib/ui/card_browser/card_detail_screen.dart`)

---

## Phase 6: Audio Feedback

**Goal**: Price-tier audio tones during scanning.

- [ ] T017 Create audio assets: three short tones for price tiers — low (<$1), mid ($1-$10), high (>$10) (`assets/audio/tone_low.mp3`, `tone_mid.mp3`, `tone_high.mp3`)
- [ ] T018 Add `just_audio` dependency, integrate into scanner: after card identified, play price tier tone based on matched card's price (`lib/ui/scanner/scanner_screen.dart`, `pubspec.yaml`)
- [ ] T019 Add audio toggle in scanner settings sheet: enable/disable scan sounds (`lib/ui/scanner/widgets/scanner_settings_sheet.dart`)

---

## Phase 7: UI Polish Pass

**Goal**: Bring all screens to daily-driver quality.

- [ ] T020 Add loading states: skeleton loaders for card search results, binder contents, card detail image loading (`lib/ui/core/widgets/`)
- [ ] T021 Add empty states: empty binder ("No cards yet — search or scan to add"), empty search results, empty wishlist (`lib/ui/core/widgets/`)
- [ ] T022 Add error states: network errors, DB errors, import parse errors — consistent error display with retry option (`lib/ui/core/widgets/`)
- [ ] T023 Add animations: screen transitions, card list item appear, binder create/delete, scan confirmation (`lib/ui/`)
- [ ] T024 Theme polish: consistent spacing, typography, color scheme across all screens — Material 3 adherence (`lib/ui/core/theme/`)

---

## Phase 8: Verification

**Goal**: Confirm all Phase 5 features work.

- [ ] T025 Test CSV import: export from Manabox → import into Manab → verify card count, metadata, and prices match
- [ ] T026 Test CSV export: export from Manab → import into Manabox → verify cards recognized
- [ ] T027 Test import/export round-trip: CSV export → CSV import → verify identical collection
- [ ] T028 Test bulk edit: select 10 cards → change condition to LP → verify all 10 updated
- [ ] T029 Test collector mode: view a set with some cards owned → verify grid correctly shows owned vs missing
- [ ] T030 Test wishlist: add 5 cards → acquire 2 (move to binder) → verify wishlist has 3, binder has 2
- [ ] T031 Test audio feedback: scan cards of different values → verify correct tones play
- [ ] T032 Test UI polish: walk through all screens → verify no missing loading/empty/error states, animations smooth at 60fps
