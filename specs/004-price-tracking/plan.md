# Implementation Plan: Price Tracking + Insights

**Branch**: `004-price-tracking` | **Date**: 2026-03-10 | **Spec**: [spec.md](./spec.md)

## Summary

Add daily price snapshots for collection cards, price history charts, collection value over time tracking, gain/loss per card, and an insights screen. Turn the collection into a portfolio view.

## Technical Context

**Language/Version**: Dart 3.10+, Flutter 3.38+
**Primary Dependencies**: `drift`, `fl_chart` (or similar), `workmanager` (background tasks)
**Storage**: SQLite `PriceRecord` table — one row per card per day
**Testing**: Unit tests for price calculation, snapshot logic
**Target Platform**: Android (arm64-v8a)
**Project Type**: Flutter mobile app — data + UI extension
**Performance Goals**: Price chart rendering <100ms, background refresh non-blocking
**Constraints**: Scryfall prices stale after ~24h; must respect API rate limits during bulk refresh
**Scale/Scope**: ~6 new source files, 1 new Drift table, DB migration v3 → v4

## Project Structure

### Source Code (new/modified files)

```text
lib/
├── domain/
│   └── price_record.dart                  # NEW
├── data/
│   ├── database/
│   │   ├── tables/
│   │   │   └── price_records_table.dart   # NEW
│   │   ├── daos/
│   │   │   └── price_records_dao.dart     # NEW
│   │   └── migrations/
│   │       └── migration_v3_to_v4.dart    # NEW
│   ├── repositories/
│   │   └── price_repository.dart          # NEW
│   └── services/
│       └── price_refresh_service.dart     # NEW: background daily refresh
└── ui/
    ├── prices/
    │   ├── insights_screen.dart           # NEW
    │   ├── insights_view_model.dart       # NEW
    │   └── widgets/
    │       ├── value_chart.dart           # NEW: collection value over time
    │       ├── price_sparkline.dart       # NEW: per-card price history
    │       └── gain_loss_badge.dart       # NEW
    ├── card_browser/
    │   └── card_detail_screen.dart        # MODIFIED: add price sparkline + gain/loss
    └── collection/
        └── collection_screen.dart         # MODIFIED: add value trend indicator
```

## Key Decisions

| Decision | Rationale |
| -------- | --------- |
| One snapshot row per card per day | Simple, predictable storage growth; sufficient granularity for hobby use |
| `fl_chart` for charting | Lightweight Flutter-native charts, no web view overhead |
| `workmanager` for background refresh | Standard Android background task scheduling; works when app is backgrounded |
| Gain/loss requires purchase price | Only shown when user has set a purchase price on the card entry |
| Refresh all collection cards daily | Simpler than tracking staleness per-card; batch API calls efficient |

## Prior Decisions Referenced

From **001-card-database**:
- Scryfall/TCGdex API services exist — reuse for price fetching
- `CachedCard` already stores current prices — this adds historical snapshots

From **002-collection-management**:
- `CardEntry` has `purchasePrice` field for gain/loss calculation
- Collection screen exists — extend with value trend

## Downstream Dependencies

This milestone exposes:
- **Price data** (006): Used in verification tests and benchmarks

## Complexity Tracking

Low-medium complexity. Main considerations:
- Background task reliability on Android (Doze mode, battery optimization)
- Storage growth: 1000 cards × 365 days × ~40 bytes = ~14MB/year — acceptable
