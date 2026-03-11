---
feature: "Price Tracking + Insights"
status: draft
tier: simple
created: 2026-03-10
depends_on: ["002"]
---

# 004 - Price Tracking + Insights

## Summary

Turn the collection into a portfolio. Store daily price snapshots, show price history graphs, track collection value over time, and display gain/loss per card.

## User Stories

### US-001: See price history for a card (Priority: P0)

**As a** collector
**I want** to see how a card's price has changed over time
**So that** I can make informed buying/selling decisions

**Acceptance Criteria:**
- GIVEN a card in my collection WHEN I view its detail THEN a price history sparkline/chart is displayed
- GIVEN the price chart WHEN I inspect it THEN it shows daily price data points

### US-002: Track collection value over time (Priority: P0)

**As a** collector
**I want** to see how my total collection value changes
**So that** I can understand my collection as an investment

**Acceptance Criteria:**
- GIVEN the home screen WHEN I view it THEN a value trend indicator shows direction (up/down)
- GIVEN the insights screen WHEN I view it THEN a collection value over time chart is displayed (per binder and total)

### US-003: See gain/loss per card (Priority: P1)

**As a** collector
**I want** to see gain/loss versus my purchase price
**So that** I know which cards appreciated or depreciated

**Acceptance Criteria:**
- GIVEN a card with a purchase price WHEN I view its detail THEN gain/loss is shown (current price − purchase price)
- GIVEN the insights screen WHEN I sort THEN I can sort by biggest movers, most valuable, or price change

### US-004: Automatic daily price refresh (Priority: P1)

**As a** collector
**I want** prices to update automatically
**So that** my collection value stays current without manual effort

**Acceptance Criteria:**
- GIVEN the app is running WHEN 24h have passed since last refresh THEN prices update in the background
- GIVEN a price refresh WHEN complete THEN card prices and collection values reflect new data

## Tasks

- T4.1: `PriceRecord` table — Drift table for daily price snapshots (cardId, date, priceUsd, priceEur, foilUsd, foilEur)
- T4.2: Daily price snapshot job — capture current prices for all collection cards
- T4.3: Background price refresh — trigger every 24h, respect API rate limits
- T4.4: Card detail update — add price history sparkline/chart, gain/loss vs purchase price
- T4.5: Home screen update — collection value trend indicator
- T4.6: Insights screen — collection value over time chart, most valuable cards, biggest movers
- T4.7: Sort/filter by price change — in binder view and insights

## Technical Notes

- Price refresh: Scryfall prices are stale after ~24h; TCGdex similar
- Storage: one row per card per day in `PriceRecord` table
- Charts: sparkline for card detail, full chart for insights (use `fl_chart` or similar)
- Background refresh: use `workmanager` or similar for periodic background tasks
- Gain/loss calculation: current price − purchase price (if purchase price set)

## Exit Criteria

Can see how collection value has changed over the past month.

## Out of Scope

- Real-time price alerts or notifications
- Price prediction or analytics
- External portfolio tracking integration
- Purchase price auto-detection from scanning
