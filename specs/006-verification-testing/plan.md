# Implementation Plan: Verification + Testing

**Branch**: `006-verification-testing` | **Date**: 2026-03-10 | **Spec**: [spec.md](./spec.md)

## Summary

Comprehensive quality assurance before v1.0: write and run unit tests, integration tests, build a scanner accuracy test corpus, run performance benchmarks, and complete a manual QA checklist. This phase produces no new features — only confidence that existing features work correctly.

## Technical Context

**Language/Version**: Dart 3.10+, Flutter 3.38+
**Primary Dependencies**: `flutter_test`, `mockito`, `integration_test`
**Testing**: Unit tests (Dart VM), integration tests (on-device), scanner accuracy (automated with test images)
**Target Platform**: Android (arm64-v8a) — Pixel 8a, Pixel 10 Pro
**Project Type**: Test suite + benchmarks
**Performance Goals**: All benchmarks defined in spec (cold start <3s, search <100ms, etc.)
**Constraints**: Scanner test corpus requires physical card photography; on-device tests require connected device
**Scale/Scope**: ~30 test files, 100 test photos, ~80 individual test cases

## Project Structure

### Source Code

```text
test/
├── domain/
│   ├── card_test.dart
│   ├── card_entry_test.dart
│   └── binder_test.dart
├── data/
│   ├── daos/
│   │   ├── cards_dao_test.dart
│   │   ├── binders_dao_test.dart
│   │   ├── card_entries_dao_test.dart
│   │   └── card_hashes_dao_test.dart
│   ├── repositories/
│   │   ├── card_repository_test.dart
│   │   ├── binder_repository_test.dart
│   │   └── scanner_repository_test.dart
│   └── services/
│       ├── export_service_test.dart
│       ├── import_service_test.dart
│       └── scanner_service_test.dart

integration_test/
├── api_client_test.dart
├── db_lifecycle_test.dart
├── db_migration_test.dart
├── export_import_roundtrip_test.dart
└── scanner_accuracy_test.dart

testing/
├── fakes/
│   ├── fake_cards_dao.dart
│   ├── fake_binders_dao.dart
│   └── fake_api_service.dart
├── fixtures/
│   ├── sample_cards.dart
│   ├── sample_binders.dart
│   └── sample_csv.dart
└── corpus/
    ├── mtg/                               # 50 MTG card photos
    │   ├── clean/                         # 20 clean scans
    │   ├── angled/                        # 15 angled shots
    │   ├── glare/                         # 10 glare/shadow
    │   └── foil/                          # 5 foil/holo
    ├── pokemon/                           # 50 Pokemon card photos
    │   ├── clean/
    │   ├── angled/
    │   ├── glare/
    │   └── foil/
    └── manifest.json                      # Expected card ID for each photo
```

## Key Decisions

| Decision | Rationale |
| -------- | --------- |
| mockito for fakes | Standard Dart mocking; generates type-safe mocks |
| In-memory Drift DB for unit tests | Fast, isolated, no file system needed |
| Physical test corpus | Scanner accuracy can only be validated with real photos from target hardware |
| manifest.json for ground truth | Maps each test photo to expected card ID for automated accuracy measurement |
| Benchmark on target hardware | Performance varies significantly by device; must test on actual Pixel 8a/10 Pro |

## Prior Decisions Referenced

All previous phases:
- Tests cover all data models, DAOs, repositories, and services from Phases 0-5
- Scanner accuracy tests validate Phase 3 pipeline
- Import/export round-trip tests validate Phase 5

## Downstream Dependencies

None — this is the final phase before release.

## Complexity Tracking

Medium complexity. Main efforts:
- Building the 100-photo test corpus (manual photography work)
- Scanner accuracy measurement automation
- Ensuring test coverage is meaningful (not just line coverage)
