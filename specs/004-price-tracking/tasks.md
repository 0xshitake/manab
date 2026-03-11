# Tasks: Price Tracking + Insights

**Input**: Design documents from `/specs/004-price-tracking/`
**Prerequisites**: plan.md (required), spec.md (required), 002-collection-management completed

---

## Phase 1: Data Layer

**Goal**: Add PriceRecord table and price repository.

- [ ] T001 Create `lib/domain/price_record.dart` with model: id, cardId, date, priceUsd, priceEur, priceFoilUsd, priceFoilEur, snapshotAt (`lib/domain/price_record.dart`)
- [ ] T002 Create `lib/data/database/tables/price_records_table.dart` with Drift table, composite index on `(cardId, date)`, index on `date` (`lib/data/database/tables/price_records_table.dart`)
- [ ] T003 Create `lib/data/database/daos/price_records_dao.dart`: `insertSnapshot(record)`, `getHistory(cardId, {days: 30})` → `List<PriceRecord>`, `getLatestForCards(cardIds)`, `deleteOlderThan(date)` (`lib/data/database/daos/price_records_dao.dart`)
- [ ] T004 Create `lib/data/database/migrations/migration_v3_to_v4.dart`: add `price_records` table (`lib/data/database/migrations/migration_v3_to_v4.dart`)
- [ ] T005 Update `lib/data/database/app_database.dart`: register table, bump schema to v4, wire migration (`lib/data/database/app_database.dart`)
- [ ] T006 Create `lib/data/repositories/price_repository.dart`: `snapshotCurrentPrices(cardIds)` — reads current prices from CachedCard, inserts PriceRecord rows; `getHistory(cardId, days)`, `getCollectionValueHistory(binderId, days)` (`lib/data/repositories/price_repository.dart`)

---

## Phase 2: Background Price Refresh

**Goal**: Implement automatic daily price updates.

- [ ] T007 Create `lib/data/services/price_refresh_service.dart`: fetch latest prices from Scryfall/TCGdex for all cards in collection, update `CachedCard` prices, trigger price snapshot (`lib/data/services/price_refresh_service.dart`)
- [ ] T008 Add `workmanager` dependency and configure periodic background task: run price refresh every 24h, respect API rate limits (batch requests with throttle) (`lib/main.dart`, `pubspec.yaml`)
- [ ] T009 Add stale price detection: compare `priceUpdatedAt` on CachedCard to current time, mark stale if >24h (`lib/data/services/price_refresh_service.dart`)

---

## Phase 3: Price Charts + UI

**Goal**: Build price visualization widgets and insights screen.

- [ ] T010 Add `fl_chart` dependency to `pubspec.yaml` (`pubspec.yaml`)
- [ ] T011 Create `lib/ui/prices/widgets/price_sparkline.dart`: small sparkline chart for card detail, shows 30-day price history, tap to expand (`lib/ui/prices/widgets/price_sparkline.dart`)
- [ ] T012 Create `lib/ui/prices/widgets/gain_loss_badge.dart`: colored badge showing +$X.XX or -$X.XX (current price − purchase price), green for gain, red for loss (`lib/ui/prices/widgets/gain_loss_badge.dart`)
- [ ] T013 Create `lib/ui/prices/widgets/value_chart.dart`: line chart showing collection value over time, supports per-binder and total views (`lib/ui/prices/widgets/value_chart.dart`)
- [ ] T014 Update `lib/ui/card_browser/card_detail_screen.dart`: add price sparkline below price display, add gain/loss badge when card has purchase price (`lib/ui/card_browser/card_detail_screen.dart`)

---

## Phase 4: Insights Screen

**Goal**: Build the portfolio insights view.

- [ ] T015 Create `lib/ui/prices/insights_view_model.dart`: Riverpod notifier computing collection value history, most valuable cards, biggest movers (price change %), sort options (`lib/ui/prices/insights_view_model.dart`)
- [ ] T016 Create `lib/ui/prices/insights_screen.dart`: collection value chart at top, tabs for "Most Valuable" and "Biggest Movers" card lists, filter by binder (`lib/ui/prices/insights_screen.dart`)
- [ ] T017 Update `lib/ui/collection/collection_screen.dart`: add value trend indicator next to total value (up/down arrow + percentage) (`lib/ui/collection/collection_screen.dart`)
- [ ] T018 Update `lib/config/router.dart`: add route for insights screen, add navigation from home screen (`lib/config/router.dart`)

---

## Phase 5: Verification

**Goal**: Confirm price tracking works end-to-end.

- [ ] T019 Test price snapshot: add cards to collection → trigger snapshot → verify PriceRecord rows created with correct prices
- [ ] T020 Test price history chart: snapshot prices for 3+ days → view card detail → verify sparkline shows data points
- [ ] T021 Test gain/loss: set purchase price on card → verify gain/loss badge shows correct delta
- [ ] T022 Test collection value chart: snapshot for multiple days → view insights → verify value chart renders
- [ ] T023 Test background refresh: leave app for 24h+ → reopen → verify prices updated and new snapshot created
- [ ] T024 Test offline behavior: enable airplane mode → verify cached prices still display, "last updated" timestamp shown
