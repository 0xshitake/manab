# Implementation Plan: Card Scanner

**Branch**: `003-card-scanner` | **Date**: 2026-03-10 | **Spec**: [spec.md](./spec.md)

## Summary

Build the full card recognition pipeline: generate a perceptual hash index from card art crops, integrate it into the app, and create the scanner UI with match confirmation, edition picker, session-based scanning, and set locking. This is the core differentiator of the app.

## Technical Context

**Language/Version**: Dart 3.10+, Flutter 3.38+
**Primary Dependencies**: `opencv_dart` v2.2.1+ (`img_hash` module), `drift`, `camera`
**Storage**: SQLite `CardHash` table (~1.4MB for hash index), bundled with card DB
**Testing**: Automated scanner accuracy tests with photo corpus (Phase 6)
**Target Platform**: Android (arm64-v8a)
**Project Type**: Flutter mobile app — scanner pipeline + UI
**Performance Goals**: Full pipeline (detect → warp → crop → hash → lookup) <200ms; hash index load <500ms
**Constraints**: Requires white background; hash threshold needs empirical tuning; full-art cards may need fallback strategy
**Scale/Scope**: ~50k hashes per game, ~8 new source files, build tool extension

## Project Structure

### Source Code (new/modified files)

```text
lib/
├── domain/
│   └── card_hash.dart                     # NEW: CardHash model
├── data/
│   ├── database/
│   │   ├── tables/
│   │   │   └── card_hashes_table.dart     # NEW
│   │   ├── daos/
│   │   │   └── card_hashes_dao.dart       # NEW: Hamming distance lookup
│   │   └── migrations/
│   │       └── migration_v2_to_v3.dart    # NEW
│   ├── repositories/
│   │   └── scanner_repository.dart        # NEW
│   └── services/
│       └── scanner_service.dart           # MODIFIED: add art crop + PHash + lookup
└── ui/
    └── scanner/
        ├── scanner_screen.dart            # MODIFIED: full scanner UI
        ├── scanner_view_model.dart        # MODIFIED: session management
        └── widgets/
            ├── match_confirmation_sheet.dart  # NEW
            ├── edition_picker.dart         # NEW
            ├── scan_session_summary.dart   # NEW
            └── scanner_settings_sheet.dart # NEW: quick mode, set lock

tool/
├── build_card_db.dart                     # MODIFIED: add hash computation step
└── phash_computer.dart                    # NEW: compute PHash via opencv_dart on desktop
```

## Key Decisions

| Decision | Rationale |
| -------- | --------- |
| RGB PHash (not grayscale) | Reduces hash collisions between cards with similar structure but different colors |
| Art crop only (not full card) | Eliminates frame/border differences across editions; reduces foil/holo interference |
| SQLite Hamming distance | Fast enough for ~50k entries (~1ms); no need for external index like VP-tree |
| Session-based scanning | Batch workflow matches real use: scan stack → review → commit. Prevents accidental duplicates |
| Hamming threshold ≤10 | Starting point; will tune empirically in Phase 6 testing |
| 2015 MTG frame as default crop | Covers 95%+ of actively collected cards |
| SV/SM Pokemon frame as default crop | Current era, covers most recent sets |

## Prior Decisions Referenced

From **000-opencv-poc**:
- Camera setup, NV21 conversion, card border detection, perspective warp all exist
- Scanner service has detection pipeline — extend with art crop, hash, lookup

From **001-card-database**:
- `AppDatabase` + `CachedCards` table for card metadata lookups
- Build tool exists — extend with PHash computation step

From **002-collection-management**:
- `BinderRepository` for committing scan session results
- `CardEntry` model for creating entries from scan matches

## Downstream Dependencies

This milestone exposes:
- **Scanner screen** (005): Extended with audio feedback
- **Scanner accuracy data** (006): Test corpus validates pipeline quality
- **Hash index** (006): Used in scanner accuracy benchmarks

## Complexity Tracking

**High complexity feature.** Key risks:
1. Hash accuracy — needs empirical testing with real cards (deferred to Phase 6)
2. Full-art card handling — standard crop rect won't work; may need fallback (open question)
3. Build tool performance — computing hashes for ~115k cards takes hours; need caching/resumption
4. Hamming distance threshold — too low = missed matches, too high = false positives
