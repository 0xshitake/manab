# Implementation Plan: Card Database + Search

**Branch**: `001-card-database` | **Date**: 2026-03-10 | **Spec**: [spec.md](./spec.md)

## Summary

Build the card data layer: import card metadata from Scryfall (MTG) and TCGdex (Pokemon) into a local Drift/SQLite database, ship a pre-built DB as a bundled asset, and create search + card detail screens with price display. Also implement per-set image downloading for offline use.

## Technical Context

**Language/Version**: Dart 3.10+, Flutter 3.38+
**Primary Dependencies**: `drift`, `sqlite3_flutter_libs`, `dio`, `cached_network_image`
**Storage**: SQLite via Drift — bundled card DB (~30MB) + user-downloaded set images
**Testing**: Unit tests for data model serialization, API client mocking
**Target Platform**: Android (arm64-v8a)
**Project Type**: Flutter mobile app — data + UI layer
**Performance Goals**: Search type-ahead <100ms, DB extraction <5s on Pixel 8a
**Constraints**: Scryfall requires User-Agent header, 50-100ms between requests; TCGdex has no documented rate limits
**Scale/Scope**: ~115k cards across MTG + Pokemon, ~30MB DB, ~20 source files

## Project Structure

### Documentation (this feature)

```text
specs/001-card-database/
  spec.md
  plan.md
  tasks.md
```

### Source Code

```text
lib/
├── domain/
│   ├── card.dart                          # CachedCard model
│   └── game_mode.dart                     # (from Phase 0)
├── data/
│   ├── database/
│   │   ├── app_database.dart              # Drift @DriftDatabase definition
│   │   ├── tables/
│   │   │   └── cards_table.dart           # CachedCards Drift table
│   │   └── daos/
│   │       └── cards_dao.dart             # Search, CRUD, bulk insert
│   ├── repositories/
│   │   └── card_repository.dart           # Abstract + impl
│   └── services/
│       ├── scryfall_api_service.dart       # Scryfall bulk data + card API
│       ├── tcgdex_api_service.dart         # TCGdex card API
│       └── db_extraction_service.dart      # Extract bundled DB on first launch
└── ui/
    ├── core/
    │   └── widgets/
    │       └── game_mode_picker.dart       # First launch game selection
    ├── card_browser/
    │   ├── card_browser_screen.dart        # Search screen
    │   ├── card_detail_screen.dart         # Full card detail + prices
    │   ├── card_browser_view_model.dart
    │   └── widgets/
    │       ├── card_search_bar.dart
    │       ├── card_list_tile.dart
    │       └── price_display.dart
    └── settings/
        ├── settings_screen.dart
        └── widgets/
            └── downloaded_sets_manager.dart

tool/
├── build_card_db.dart                     # Main build script
├── scryfall_client.dart
├── tcgdex_client.dart
└── db_packer.dart

assets/
└── cards.db                               # Pre-built bundled card DB
```

## Key Decisions

| Decision | Rationale |
| -------- | --------- |
| Drift over raw sqflite | Type-safe queries, compile-time SQL checks, reactive streams, built-in migrations, DAO pattern |
| Bundled DB as compressed asset | Faster first launch (~2-5s extraction) vs downloading on first launch |
| Game mode scoped search | Only query active game's cards — reduces result set, cleaner UX |
| Firefox User-Agent | Per Scryfall/TCGdex terms — respectful, non-commercial identification |
| Per-set image download | User chooses which sets — controls storage usage, enables offline browsing |
| `dio` with interceptors | Rate limiting enforcement, retry logic, consistent error handling |

## Prior Decisions Referenced

From **000-opencv-poc**:
- Project scaffold, folder structure, and dependency configuration exist
- `GameMode` enum defined in `domain/game_mode.dart`
- Riverpod + go_router infrastructure in place

## Downstream Dependencies

This milestone exposes the following for downstream specs:
- **`AppDatabase`** (002-006): Drift database instance, shared across all features
- **`CachedCard` table + DAO** (002-005): Card lookup, search, price access
- **`CardRepository`** (002-003): Card data access for collection and scanner
- **API services** (004): Price refresh reuses Scryfall/TCGdex clients
- **Card detail screen** (002): Extended with "Add to binder" in Phase 2
- **Build tool** (003): Extended with PHash computation in Phase 3
- **Settings screen** (002-005): Extended with more options over time

## Complexity Tracking

Primary complexity: Scryfall bulk data import pipeline — ~500MB JSON download, parsing ~115k cards. Mitigated by running on dev machine (build tool), not on-device.

Secondary complexity: DB extraction on first launch — compressed asset extraction timing. Need to test on target hardware.
