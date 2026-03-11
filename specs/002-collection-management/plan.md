# Implementation Plan: Collection Management

**Branch**: `002-collection-management` | **Date**: 2026-03-10 | **Spec**: [spec.md](./spec.md)

## Summary

Add the collection tracking layer: binder CRUD, card entries with full metadata (quantity, language, foil, condition, purchase price), collection value summaries, and JSON export. This turns the app from a card browser into a collection manager.

## Technical Context

**Language/Version**: Dart 3.10+, Flutter 3.38+
**Primary Dependencies**: `drift`, `flutter_riverpod`, `go_router`, `uuid`
**Storage**: SQLite via Drift — `Binder` and `CardEntry` tables added to existing `AppDatabase`
**Testing**: Unit tests for binder CRUD, value calculation, export format
**Target Platform**: Android (arm64-v8a)
**Project Type**: Flutter mobile app — data + UI layer extension
**Performance Goals**: Binder list reactive updates <50ms, value calculation instant for <1000 cards
**Constraints**: Binders are game-scoped; value calculation uses cached prices from Phase 1 DB
**Scale/Scope**: ~15 new source files, 2 new Drift tables, DB migration v1 → v2

## Project Structure

### Source Code (new/modified files)

```text
lib/
├── domain/
│   ├── binder.dart                        # NEW: Binder model
│   └── card_entry.dart                    # NEW: CardEntry model
├── data/
│   ├── database/
│   │   ├── app_database.dart              # MODIFIED: add Binder + CardEntry tables, bump schema
│   │   ├── tables/
│   │   │   ├── binders_table.dart         # NEW
│   │   │   └── card_entries_table.dart    # NEW
│   │   ├── daos/
│   │   │   ├── binders_dao.dart           # NEW
│   │   │   └── card_entries_dao.dart      # NEW
│   │   └── migrations/
│   │       └── migration_v1_to_v2.dart    # NEW
│   ├── repositories/
│   │   └── binder_repository.dart         # NEW
│   └── services/
│       └── export_service.dart            # NEW: JSON export
└── ui/
    ├── collection/
    │   ├── collection_screen.dart          # NEW: home / binder list
    │   ├── binder_detail_screen.dart       # NEW: cards in binder
    │   ├── collection_view_model.dart      # NEW
    │   └── widgets/
    │       ├── binder_list_tile.dart       # NEW
    │       ├── card_entry_tile.dart        # NEW
    │       ├── add_to_binder_sheet.dart    # NEW
    │       └── binder_create_dialog.dart   # NEW
    ├── card_browser/
    │   └── card_detail_screen.dart         # MODIFIED: add "Add to binder" button
    └── settings/
        └── settings_screen.dart            # MODIFIED: add export option
```

## Key Decisions

| Decision | Rationale |
| -------- | --------- |
| Binders scoped to game mode | Simplifies UI, matches user mental model (MTG and Pokemon are separate collections) |
| CardEntry stores denormalized name/set | Allows offline display without joining CachedCard; data is small |
| Condition enum nullable | New users shouldn't be forced to grade condition on every card |
| Purchase price nullable | Optional — many collectors don't track purchase price |
| Drift migration v1→v2 | Adding tables requires explicit schema migration for existing installs |
| JSON export first, CSV later | JSON is simpler, self-describing; CSV (Manabox-compat) deferred to Phase 5 |

## Prior Decisions Referenced

From **001-card-database**:
- `AppDatabase` exists with `CachedCards` table
- `CardsDao` provides card lookup by ID
- Card detail screen exists — extend with "Add to binder"
- Settings screen exists — extend with export
- Game mode state provider exists

## Downstream Dependencies

This milestone exposes:
- **`Binder` + `CardEntry` tables** (003-005): Scanner adds to binders, price tracking uses entries
- **`BinderRepository`** (003): Scanner commit writes entries via this
- **`ExportService`** (005): Extended with CSV export
- **Collection screen** (004): Extended with value trend indicators
- **Card detail** (004): Extended with price history chart

## Complexity Tracking

Low complexity. Standard CRUD with reactive Drift streams. Main consideration is the DB migration — must preserve existing card data when adding new tables.
