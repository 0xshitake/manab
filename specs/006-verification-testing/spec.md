---
feature: "Verification + Testing"
status: draft
tier: complex
created: 2026-03-10
depends_on: ["000", "001", "002", "003", "004", "005"]
---

# 006 - Verification + Testing

## Summary

Prove everything works end-to-end before calling it v1.0. Comprehensive unit tests, integration tests, scanner accuracy tests with a real photo corpus, edge case coverage, performance benchmarks, and manual QA.

## User Stories

### US-001: All automated tests pass (Priority: P0)

**As a** developer
**I want** comprehensive automated test coverage
**So that** I can ship with confidence and catch regressions

**Acceptance Criteria:**
- GIVEN the test suite WHEN I run `flutter test` THEN all unit tests pass
- GIVEN integration tests WHEN I run on-device THEN all integration tests pass
- GIVEN scanner tests WHEN I run against the test corpus THEN accuracy meets targets

### US-002: Scanner accuracy meets targets (Priority: P0)

**As a** developer
**I want** measured scanner accuracy on a real test corpus
**So that** I know the scanner is reliable for users

**Acceptance Criteria:**
- GIVEN 100 test photos (50 MTG + 50 Pokemon) WHEN run through the full pipeline THEN detection rate >95% for clean scans
- GIVEN clean scan images WHEN matched THEN top-1 accuracy >90%, top-3 accuracy >95%
- GIVEN end-to-end pipeline WHEN measured THEN latency <200ms on target phone

### US-003: Manual QA passes (Priority: P0)

**As a** developer
**I want** to verify all user flows manually
**So that** the app works as expected in real usage

**Acceptance Criteria:**
- GIVEN the QA checklist WHEN I complete every item THEN all pass without P0/P1 bugs

## Requirements

### Unit Tests (Dart)

- **UT-001**: Card data model serialization/deserialization (JSON ↔ CardEntry, CachedCard)
- **UT-002**: Binder CRUD operations (create, rename, delete, add/remove cards)
- **UT-003**: Collection value calculation (sum prices × quantities, foil vs regular)
- **UT-004**: Price refresh logic (stale detection, delta merge)
- **UT-005**: Export format correctness (JSON structure matches spec, CSV matches Manabox format)
- **UT-006**: Game mode filtering (binders, search results, hash index scoped to active game)
- **UT-007**: Hamming distance calculation correctness
- **UT-008**: Perceptual hash determinism (same image always produces same hash)

### Integration Tests (On-Device)

- **IT-001**: Scryfall API client — fetch card by name, parse response, handle rate limits + errors
- **IT-002**: TCGdex API client — fetch card by ID, parse response, handle unavailable cards
- **IT-003**: DB lifecycle — fresh install → populate from bulk data → query → delta update → verify integrity
- **IT-004**: DB migrations — upgrade schema from v1 → v2, verify data preserved
- **IT-005**: Export → import round-trip — export binder to JSON → clear DB → import → verify identical

### Scanner Accuracy Tests

Test corpus: 100 card photos (50 MTG + 50 Pokemon) taken with target phone:
- 20 clean scans (white bg, good lighting, straight angle)
- 15 slightly angled (±15°)
- 10 with moderate glare/shadow
- 5 foil/holo cards

Metrics:
- **Detection rate**: >95% for clean scans
- **Top-1 accuracy**: >90% for clean scans
- **Top-3 accuracy**: >95% for clean scans
- **Latency**: <200ms end-to-end on target phone
- **Foil degradation**: measure accuracy drop on holo/foil subset (establish baseline)

### Edge Case Tests

- **EC-001**: Card not in database → graceful "no match" with manual search fallback
- **EC-002**: Duplicate scan in session → quantity increments, not duplicate entries
- **EC-003**: Very low-value card ($0.01) → still identified, price displays correctly
- **EC-004**: Same artwork in 5+ sets → all editions shown in picker
- **EC-005**: Empty binder export → valid JSON with empty cards array
- **EC-006**: DB corruption recovery → detect invalid state, prompt re-download
- **EC-007**: Network offline during price refresh → use cached prices, show "last updated"
- **EC-008**: Switch game mode mid-session → scanner restarts with new hash index

### Performance Benchmarks

- **PB-001**: App cold start <3s on target phone
- **PB-002**: Card search latency <100ms for type-ahead
- **PB-003**: Hash index load time <500ms per game
- **PB-004**: Scanner frame processing >15 fps for border detection
- **PB-005**: Memory usage <150MB RSS with full hash index loaded
- **PB-006**: DB size <5MB user data after 1000 cards in collection

### Manual QA Checklist

- [ ] Full walkthrough: install → search → create binder → add 10 cards → verify prices → export JSON → verify
- [ ] Scanner walkthrough: scan 20 cards → review session → correct 2 misidentifications → commit → verify
- [ ] Game mode: switch MTG → Pokemon → verify binders/search/scanner all reflect correct game
- [ ] Price tracking: add cards → wait 24h → verify prices updated → check value chart
- [ ] Offline: airplane mode → browse collection → search cached cards → verify no crashes
- [ ] Import: Manabox CSV export → import → verify card count + total value matches
- [ ] Stress test: 500+ cards in one binder → scroll, search, sort → verify no jank or OOM

## Exit Criteria

All unit + integration tests pass, scanner accuracy meets targets on test corpus, manual QA checklist fully passed, no P0/P1 bugs open.

## Out of Scope

- CI/CD pipeline setup
- Automated UI testing (Espresso/Appium)
- Load testing / multi-user scenarios (single-user app)
