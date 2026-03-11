# Implementation Plan: Import/Export + Polish

**Branch**: `005-import-export-polish` | **Date**: 2026-03-10 | **Spec**: [spec.md](./spec.md)

## Summary

Add Manabox-compatible CSV import/export, bulk card editing, collector mode (set completion tracking), wishlist, audio scanning feedback, and a comprehensive UI polish pass. This phase makes the app a daily driver.

## Technical Context

**Language/Version**: Dart 3.10+, Flutter 3.38+
**Primary Dependencies**: `csv` (CSV parsing), `just_audio`, `file_picker`
**Storage**: SQLite — may add wishlist table or reuse binder with type flag
**Testing**: Import/export round-trip tests, bulk edit correctness
**Target Platform**: Android (arm64-v8a)
**Project Type**: Flutter mobile app — feature completion + polish
**Performance Goals**: CSV import of 1000 cards <5s, UI animations at 60fps
**Constraints**: Manabox CSV format must be reverse-engineered from real exports; audio tones need bundled assets
**Scale/Scope**: ~12 new source files, multiple existing file modifications, UI polish across all screens

## Project Structure

### Source Code (new/modified files)

```text
lib/
├── data/
│   └── services/
│       ├── import_service.dart            # NEW: CSV import with format detection
│       └── export_service.dart            # MODIFIED: add CSV export
└── ui/
    ├── collection/
    │   ├── collector_mode_screen.dart     # NEW: set completion grid
    │   ├── wishlist_screen.dart           # NEW
    │   └── widgets/
    │       ├── bulk_edit_sheet.dart        # NEW
    │       └── set_completion_grid.dart   # NEW
    ├── scanner/
    │   └── scanner_screen.dart            # MODIFIED: add audio feedback
    └── settings/
        └── widgets/
            └── import_flow.dart           # NEW: CSV import UI with preview

assets/
├── audio/
│   ├── tone_low.mp3                       # <$1
│   ├── tone_mid.mp3                       # $1-$10
│   └── tone_high.mp3                      # >$10
```

## Key Decisions

| Decision | Rationale |
| -------- | --------- |
| Reverse-engineer Manabox CSV | Most popular MTG collection app; users migrating will have CSV exports |
| Preview before import | Users need to verify data before committing; shows parse errors upfront |
| Wishlist as separate entity | Cleaner than overloading binders with a "type" flag; wishlist has different semantics |
| Audio tones by price tier | Quick auditory feedback during fast scanning; three tiers sufficient |
| UI polish as part of this phase | Consolidate all polish work; ensures consistent quality before v1.0 |

## Prior Decisions Referenced

From **002-collection-management**:
- `ExportService` exists with JSON export — extend with CSV
- `BinderRepository` for import target
- Binder detail screen — extend with multi-select + bulk edit

From **003-card-scanner**:
- Scanner screen exists — extend with audio feedback
- `just_audio` dependency already planned

## Downstream Dependencies

This milestone is the final feature phase. Exposes:
- **Import/export** (006): Round-trip tests verify format correctness
- **All UI** (006): Manual QA checklist covers all polished screens

## Complexity Tracking

Medium complexity. Main challenges:
- Manabox CSV format: need a real export to reverse-engineer exact column names/order
- Bulk edit UX: multi-select + batch update needs careful state management
- Set completion: querying all cards in a set vs owned cards efficiently
