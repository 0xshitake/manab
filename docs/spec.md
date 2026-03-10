# Manab — TCG Collection Manager

## Overview

Android application for managing Magic: The Gathering and Pokemon TCG card collections with camera-based card recognition and price tracking. Local-first, no account required.

**Name:** Manab (working title)
**Platform:** Android-first (Flutter/Dart — cross-platform ready)
**Architecture:** Local-first, offline-capable, no backend

---

## Goals

1. Scan physical cards with the phone camera to identify them
2. Organize cards into named collections (binders)
3. Track collection value over time using market prices
4. Support both MTG and Pokemon TCG
5. Export collection data for use in other tools

## Non-Goals (for now)

- Deck building
- Trading/social features
- Cloud sync or user accounts
- iOS or web versions (Flutter makes this possible later with minimal effort)
- Card condition grading via camera
- Marketplace integration (buying/selling)

---

## Phase Plan

### Phase 0 — Project Scaffold + OpenCV Proof of Concept
> Prove the hardest tech risk before building anything else.

- Flutter project setup (folder structure, linting, dependencies)
- Camera preview screen (full-screen, CameraX backend)
- OpenCV integration via `opencv_dart` (v2.2.1+ — full OpenCV 4.13 bindings, async API)
- Card border detection: grayscale → Canny edges → findContours → largest quad
- Perspective warp: crop and normalize detected card to standard size (672×936 MTG / 734×1024 Pokemon)
- Display the warped card image on screen as confirmation
- Test on target phone with real cards on white background
- **Exit criteria:** app reliably detects and crops a card from camera feed in <100ms

### Phase 1 — Card Database + Search
> Make the app useful for browsing cards and checking prices, even without a collection.

- Scryfall bulk data import pipeline (download JSON → parse → insert into local DB)
- TCGdex API integration (Pokemon cards, English + Spanish)
- Local SQLite database via Drift (type-safe, reactive streams, built-in migrations)
- First launch: pick game mode → extract bundled card DB → ready to browse
- Card search screen (text search, scoped to active game mode)
- Card detail screen (full image, set, rarity, type, prices USD + EUR)
- Price display per card (regular + foil)
- Offline card browsing (full DB cached locally)
- Set-based image download (user picks sets → app downloads all card images for that set to local storage)
- Downloaded sets manager in settings (shows sets, storage used, delete option)
- DB update mechanism (check for new sets on app launch, download deltas)
- **Exit criteria:** can search any MTG or Pokemon card by name, see its current price, and download a set's images for offline use

### Phase 2 — Collection Management
> Start tracking what you own.

- Binder management (create, rename, delete)
- Add cards to binder via search (tap card → pick binder → set quantity/language/foil)
- Per-card metadata: quantity, language, foil/non-foil, condition, purchase price, notes
- Binder detail view (card list, sortable by name/set/price/date added)
- Filter within binder (by game, search by name)
- Collection value summary per binder and total
- Home screen: binder list with card count + value each
- Export collection to JSON
- **Exit criteria:** can manage a full collection manually, see total value, export it

### Phase 3 — Card Scanner
> Camera-based card recognition — the core differentiator.

- Perceptual hash index build pipeline (CI job: download art crops → compute RGB phash → pack into DB)
- Ship pre-built hash index with the app (~30-50MB SQLite, bundled as asset)
- Scanner screen: camera preview + card border overlay from Phase 0
- Art region crop (fixed ratios per game — MTG vs Pokemon art box positions)
- RGB perceptual hash of cropped art region
- Hamming distance lookup against hash index (top-N candidates)
- Match confirmation UI: bottom sheet with best match, tap to cycle alternatives
- Edition picker for same-artwork reprints
- Session-based scanning (scan batch → review all → commit to binder)
- Set locking (restrict matches to specific sets for bulk scanning)
- Quick mode (auto-confirm best match) vs manual mode
- **Exit criteria:** can scan a stack of cards on a white background and add them to a binder

### Phase 4 — Price Tracking + Insights
> Turn the collection into a portfolio.

- Price history storage (snapshot prices daily for cards in collection)
- Price history graph per card (sparkline or full chart)
- Collection value over time chart (per binder and total)
- Daily background price refresh
- Gain/loss per card (current price vs purchase price)
- Sort/filter collection by price change, most valuable, etc.
- **Exit criteria:** can see how collection value has changed over the past month

### Phase 5 — Import/Export + Polish
> Interoperability and daily-driver quality.

- Import from CSV (Manabox-compatible format)
- Export to CSV (Manabox-compatible format)
- Bulk edit (select multiple cards → change language/condition/foil/etc.)
- Collector mode (set completion grid — owned vs missing, grouped by set/rarity)
- Wishlist / want list (separate from binders)
- Audio feedback during scanning (price tier tones: <$1, $1-$10, >$10)
- UI polish pass (animations, loading states, error handling, empty states)
- **Exit criteria:** can import a Manabox CSV export and see full collection with prices

### Phase 6 — Verification + Testing
> Prove everything works end-to-end before calling it v1.0.

**Unit tests (Dart):**
- Card data model serialization/deserialization (JSON ↔ CardEntry, CachedCard)
- Binder CRUD operations (create, rename, delete, add/remove cards)
- Collection value calculation (sum prices × quantities, foil vs regular)
- Price refresh logic (stale detection, delta merge)
- Export format correctness (JSON structure matches spec, CSV matches Manabox format)
- Game mode filtering (binders, search results, hash index scoped to active game)
- Hamming distance calculation correctness
- Perceptual hash determinism (same image always produces same hash)

**Integration tests (on-device):**
- Scryfall API client: fetch card by name, parse response, handle rate limits + errors
- TCGdex API client: fetch card by ID, parse response, handle unavailable cards
- DB lifecycle: fresh install → populate from bulk data → query → delta update → verify integrity
- DB migrations: upgrade schema from v1 → v2, verify data preserved
- Export → import round-trip: export binder to JSON → clear DB → import → verify identical

**Scanner accuracy tests (automated with test images):**
- Build a test corpus: 100 card photos (50 MTG + 50 Pokemon) taken with target phone
  - 20 clean scans (white bg, good lighting, straight angle)
  - 15 slightly angled (±15°)
  - 10 with moderate glare/shadow
  - 5 foil/holo cards
- For each test image, run the full pipeline: detect → warp → crop art → hash → lookup
- Measure:
  - **Detection rate**: % of images where card border is found (target: >95% for clean scans)
  - **Top-1 accuracy**: % where best match is correct card (target: >90% for clean scans)
  - **Top-3 accuracy**: % where correct card is in top 3 candidates (target: >95% for clean scans)
  - **Latency**: end-to-end time from image to match (target: <200ms on target phone)
  - **Foil degradation**: measure accuracy drop on holo/foil subset (establish baseline)

**Edge case tests:**
- Card not in database (new set not yet indexed) → graceful "no match" with manual search fallback
- Duplicate scan (same card scanned twice in one session) → quantity increments, not duplicate entries
- Very low-value card ($0.01) → still identified, price displays correctly
- Card with same artwork in 5+ sets → all editions shown in picker, correct set selectable
- Empty binder export → valid JSON with empty cards array
- DB corruption recovery → detect invalid state, prompt re-download of card DB
- Network offline during price refresh → use cached prices, show "last updated" timestamp
- Switch game mode mid-session → scanner restarts with new hash index

**Performance benchmarks:**
- App cold start time (target: <3s on target phone)
- Card search latency (target: <100ms for type-ahead results)
- Hash index load time per game (target: <500ms)
- Scanner frame processing rate (target: >15 fps for border detection)
- Memory usage with full hash index loaded (target: <150MB RSS)
- DB size after 1000 cards in collection (target: <5MB user data)

**Manual QA checklist:**
- [ ] Full walkthrough: install → search card → create binder → add 10 cards manually → verify prices → export JSON → verify JSON
- [ ] Scanner walkthrough: scan 20 cards → review session → correct 2 misidentifications → commit to binder → verify all added
- [ ] Game mode: switch MTG → Pokemon → verify binders/search/scanner all reflect correct game
- [ ] Price tracking: add cards → wait 24h → verify prices updated → check value chart
- [ ] Offline: enable airplane mode → browse collection → search cached cards → verify no crashes
- [ ] Import: take Manabox CSV export → import → verify card count + total value matches
- [ ] Stress test: add 500+ cards to one binder → scroll, search, sort → verify no jank or OOM

- **Exit criteria:** all unit + integration tests pass, scanner accuracy meets targets on test corpus, manual QA checklist fully passed, no P0/P1 bugs open

### Phase 7 — Future / Nice-to-Have

- Multi-language card name search (search Spanish name, find English card)
- OCR fallback for cards that fail hash matching
- Foil detection heuristics (multi-frame voting)
- Barcode/QR scanning for sealed products (set identification)
- Companion web viewer (read-only, export-based)
- Share binder as link (static HTML export)
- Home screen widget for collection value
- iOS release (Flutter makes this low-effort)

---

## Target Devices

| Device | SoC | RAM | Main Camera | Android |
|---|---|---|---|---|
| Pixel 8a | Tensor G3 (Cortex-X3) | 8 GB | 64MP f/1.89, OIS | 14+ |
| Pixel 10 Pro | Tensor G5 (3.4GHz X4) | 16 GB | 50MP f/1.68, OIS | 15+ |

Both support full CameraX/Camera2 APIs. NV21 image format for efficient OpenCV conversion.
Minimum Android API: **26** (Android 8.0) — covers 95%+ active devices.

---

## Distribution

Side-loaded APK for now. No Play Store.

```bash
# Build arm64 release APK (both Pixels are arm64-v8a)
flutter build apk --split-per-abi --release

# Install via adb
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

**Expected APK size:** ~80-100 MB (Flutter ~5MB + OpenCV ~15-20MB + card DB ~30-50MB + app code).
Signing via local keystore — no Play Store signing needed.

---

## First Launch Flow

1. App opens → **game mode picker** (MTG or Pokemon). Full screen, two big cards/buttons.
2. Selected game's card DB is extracted from bundled assets to app documents directory.
   - Bundled as compressed SQLite asset (~15-20MB compressed, ~30-50MB extracted)
   - Show progress bar during extraction (~2-5s on Pixel 8a)
3. Land on **card search screen** — ready to browse cards and check prices.
4. Game mode can be changed later from settings or home screen toggle.

---

## Technical Architecture

### Tech Stack

> Informed by Manabox APK analysis (Flutter + OpenCV + SQLite, no ML models).
> Same proven approach, with modern packages (opencv_dart, Drift, Riverpod) and no encryption.

| Layer | Choice | Rationale |
|---|---|---|
| Framework | Flutter 3.38+ (Dart 3.10+) | Cross-platform ready; proven by Manabox at scale |
| Camera | `camera` plugin (CameraX backend) | `imageFormatGroup: ImageFormatGroup.nv21` for efficient OpenCV conversion |
| Card detection | `opencv_dart` v2.2.1+ | Full OpenCV 4.13 bindings via dart:ffi. Modules: `imgproc` (default) + `img_hash` (contrib). Async API for non-blocking processing |
| Card identification | OpenCV `PHash` (via `img_hash` module) | Native C++ DCT-based perceptual hash. Same library for both image processing and hashing |
| Database | Drift (type-safe SQLite) | Reactive `Stream<List<T>>` queries, compile-time checked SQL, built-in schema migrations, DAO pattern |
| Networking | `dio` | API calls for card data + prices, interceptors for rate limiting |
| State management | Riverpod (v3.x) | Dart-idiomatic, minimal boilerplate, `StreamProvider` integrates naturally with Drift reactive queries |
| Image loading | `cached_network_image` | Standard Flutter image caching with placeholder support |
| Audio | `just_audio` | Scan feedback tones (Phase 5) |
| Routing | `go_router` | Declarative routing, deep link support |

### Data Sources

| Source | Game | Provides | Rate Limit |
|---|---|---|---|
| [TCGdex API](https://tcgdex.dev) | Pokemon | Card data, images, CardMarket + TCGPlayer prices | Undocumented (be gentle) |
| [Scryfall API](https://scryfall.com/docs/api) | MTG | Card data, images (6 formats), USD/EUR prices | ~10 req/s; image CDN unlimited |

### Data Model

```
Binder
  ├── id: UUID
  ├── name: String
  ├── game: Enum(MTG, POKEMON)  ← set from active game mode at creation
  ├── createdAt: Timestamp
  └── updatedAt: Timestamp

CardEntry
  ├── id: UUID
  ├── binderId: UUID (FK → Binder)
  ├── game: Enum(MTG, POKEMON)
  ├── cardId: String (Scryfall UUID or TCGdex ID)
  ├── name: String
  ├── setCode: String
  ├── setName: String
  ├── collectorNumber: String
  ├── quantity: Int
  ├── foil: Boolean
  ├── language: String (ISO 639-1: "en", "es", etc.)
  ├── condition: Enum(NM, LP, MP, HP, DMG) [nullable]
  ├── purchasePrice: Decimal [nullable]
  ├── purchaseCurrency: String [nullable]
  ├── notes: String [nullable]
  ├── imageUrl: String
  ├── addedAt: Timestamp
  └── updatedAt: Timestamp

CachedCard (local card database cache)
  ├── cardId: String (PK)
  ├── game: Enum(MTG, POKEMON)
  ├── name: String
  ├── setCode: String
  ├── setName: String
  ├── collectorNumber: String
  ├── typeLine: String [nullable]
  ├── rarity: String
  ├── imageUrl: String
  ├── artCropUrl: String [nullable]
  ├── priceUsd: Decimal [nullable]
  ├── priceEur: Decimal [nullable]
  ├── priceFoilUsd: Decimal [nullable]
  ├── priceFoilEur: Decimal [nullable]
  ├── priceUpdatedAt: Timestamp [nullable]
  ├── language: String
  └── cachedAt: Timestamp

CardHash (recognition index)
  ├── cardId: String (FK → CachedCard)
  ├── game: Enum(MTG, POKEMON)
  ├── phashValue: Long (64-bit perceptual hash)
  └── setCode: String (for set-locking optimization)
```

### Card Recognition Pipeline

> Confirmed by Manabox APK: pure OpenCV pipeline, no ML models.
> Their APK contains `native_opencv` + `imagematch` modules, zero TFLite/ONNX files.

```
Camera Frame
    │
    ▼
┌──────────────────────┐
│ 1. Card Detection     │  OpenCV
│    - Grayscale +      │  Gaussian blur → Canny edge
│      edge detection   │  detection → findContours()
│    - Find largest     │  Filter for quadrilateral with
│      quadrilateral    │  card aspect ratio (~63:88)
│    - White background │  Requires high-contrast bg
│      recommended      │  (same limitation as Manabox)
└──────────┬───────────┘
           │ 4 corner points
           ▼
┌──────────────────────┐
│ 2. Perspective Warp   │  OpenCV getPerspectiveTransform()
│    - Order corners    │  + warpPerspective()
│    - Correct skew     │  Output: normalized card image
│    - Normalize to     │  MTG: 672×936, Pokemon: 734×1024
│      standard size    │  (matches Scryfall/TCGdex image sizes)
└──────────┬───────────┘
           │ normalized card image
           ▼
┌──────────────────────┐
│ 3. Art Region Crop    │  Fixed pixel rects per game
│    - Extract artwork  │  MTG (672×936): (23,98)→(649,527)
│      area only        │  Pokemon (734×1024): (60,100)→(675,482)
│    - Ignore borders,  │  Reduces foil/holo interference
│      text, holo       │  See Art Crop Reference below
└──────────┬───────────┘
           │ art crop
           ▼
┌──────────────────────┐
│ 4. Perceptual Hash    │  opencv_dart img_hash module
│    - cv.PHash.compute │  Native C++ DCT implementation
│    - 64-bit output    │  Same algorithm used in build tool
│    - Deterministic    │  and at scan time → consistent matches
└──────────┬───────────┘
           │ 64-bit hash
           ▼
┌──────────────────────┐
│ 5. Index Lookup       │  SQLite query on hash table
│    - Game mode filter │  WHERE game = active_game
│    - Hamming distance │  AND set_code IN (locked_sets)
│      against DB       │  ORDER BY hamming_dist ASC
│    - Set-lock filter  │  LIMIT top-N candidates
│    - Top-N candidates │  (~1ms for 50k entries)
└──────────┬───────────┘
           │ ranked candidates
           ▼
┌──────────────────────┐
│ 6. User Confirmation  │  UI overlay
│    - Show best match  │  Tap to cycle alternatives
│    - Set/edition pick │  Confirm or reject
│    - Add to session   │
└──────────────────────┘
```

#### Art Crop Reference

**MTG** (normalized to 672×936 — Scryfall "large" size):

| Frame Era | Rect (x,y,w,h) | % of card | Notes |
|---|---|---|---|
| 2015 frame (2014–present) | (23, 98, 626, 430) | 93.2% × 45.9% | Current standard |
| 2003 frame (8th Ed–M14) | (28, 98, 616, 430) | 91.7% × 45.9% | Same vertical, slightly narrower |
| 1993 frame (Alpha–7th) | (55, 98, 563, 430) | 83.8% × 45.9% | Same vertical, narrowest |
| Full-art | (22, 43, 628, 682) | 93.5% × 72.9% | Art fills most of card |

All traditional frames share the same vertical bounds (y=98 to y=527). **Use the 2015 frame rect as default** — it covers 95%+ of cards in active collections.

**Pokemon** (normalized to 734×1024 — TCGdex high-res size):

| Era | Rect (x,y,w,h) | % of card | Notes |
|---|---|---|---|
| SV (2023+) | (60, 100, 615, 382) | 83.8% × 37.3% | Current standard, same as SM |
| SM (2017–2019) | (60, 100, 615, 382) | 83.8% × 37.3% | Reference frame |
| XY (2013–2016) | (64, 117, 604, 394) | 82.3% × 38.5% | Art shifted down ~17px |
| SWSH (2020–2022) | (29, 30, 676, 850) | 92.1% × 83.0% | Full-bleed illustration |
| V/VMAX/ex (all eras) | Near full-art | ~90%+ | Art fills entire card |

**Use the SV/SM rect as default** — current era. Full-art cards (SWSH, V, VMAX, ex ultra-rares) will need a larger crop or full-card hash as fallback.

#### Why OpenCV over YOLO/ML

Manabox's APK proves a pure OpenCV approach works at production scale (100k+ cards, ~900k downloads). Key advantages:
- **No ML model to ship or update** — saves ~6MB+ and avoids TFLite runtime complexity
- **Deterministic** — contour detection is predictable and debuggable vs ML black box
- **Fast** — native OpenCV contour detection runs in <5ms per frame
- **Tradeoff** — requires a clean, high-contrast background (white paper). Manabox has this same limitation and users accept it (there's an entire market for 3D-printed scan stands).

### Card Database + Hash Index (shipped with app)

> Manabox ships a 78MB encrypted SQLite. We ship a plain SQLite — no encryption needed
> for a hobby project. Can add SQLCipher later if we ever publish commercially.

**Build process (local script `tool/build_card_db.dart`, not on-device):**

1. Download Scryfall bulk data JSON (~500MB for default cards)
2. Download TCGdex card data via API (all English + Spanish cards)
3. For each card, download the art crop image:
   - Scryfall: `art_crop` format (varies, JPG) — CDN has no rate limit
   - TCGdex: `high.webp` then crop art region
4. Compute perceptual hash via OpenCV `PHash` for each art crop
5. Pack into a plain SQLite DB:
   - Card metadata (name, set, prices, etc.) — the `CachedCard` table
   - Hash index (cardId → phash) — the `CardHash` table
6. Compress and bundle as a Flutter asset
7. Delta updates: on app launch, check for new sets → download incremental hash + card data via API

**Size estimates:**
- Card metadata (~115k cards × ~200 bytes avg): ~23 MB
- Hash index (~115k cards × 12 bytes): ~1.4 MB
- SQLite overhead + indexes: ~5 MB
- **Total uncompressed: ~30 MB** | Compressed asset: ~15-20 MB
- (Manabox's is 78MB with encryption overhead and likely more data)

### Hash Index Build Tool (`tool/build_card_db.dart`)

Separate Dart CLI script that runs on a dev machine. Not shipped with the app.

```
tool/
├── build_card_db.dart          # Main script: orchestrates download → hash → pack
├── scryfall_client.dart        # Download Scryfall bulk data + art crops
├── tcgdex_client.dart          # Download TCGdex cards + images
├── phash_computer.dart         # Compute PHash via opencv_dart (runs on desktop)
└── db_packer.dart              # Insert into SQLite, compress, copy to assets/
```

**Usage:**
```bash
# Full rebuild (downloads ~50GB of images, takes hours)
dart run tool/build_card_db.dart --full

# Delta update (only new sets since last build)
dart run tool/build_card_db.dart --delta

# Single game only
dart run tool/build_card_db.dart --game=mtg --delta
```

**Output:** `assets/cards.db` (compressed) → bundled into the APK at build time.

This is a Phase 3 deliverable but should be prototyped early (Phase 0/1) to validate the hash quality.

### Language Support

| Feature | English | Spanish | Other |
|---|---|---|---|
| Card search | Yes | Yes | No (Phase 7) |
| Card names in DB | Yes | Yes (via TCGdex `es` + Scryfall `lang:es`) | No |
| UI strings | Yes | Yes | No |
| Scanner | Language-agnostic (artwork-based) | Same | Same |
| Per-card language tag | Yes | Yes | Yes (manual entry) |

### Export Format

Primary export: JSON (human-readable, easy to parse elsewhere).

```json
{
  "exportedAt": "2026-03-10T12:00:00Z",
  "appVersion": "1.0.0",
  "binders": [
    {
      "name": "Main Collection",
      "cards": [
        {
          "game": "MTG",
          "name": "Lightning Bolt",
          "setCode": "2ed",
          "setName": "Unlimited Edition",
          "collectorNumber": "162",
          "scryfallId": "f29ba16f-c8fb-42fe-aabf-87089cb214a7",
          "quantity": 4,
          "foil": false,
          "language": "en",
          "condition": "LP",
          "purchasePrice": 1.50,
          "purchaseCurrency": "USD",
          "notes": null
        },
        {
          "game": "POKEMON",
          "name": "Charizard ex",
          "setCode": "sv3pt5",
          "setName": "Scarlet & Violet 151",
          "collectorNumber": "006",
          "tcgdexId": "sv3pt5-6",
          "quantity": 1,
          "foil": false,
          "language": "es",
          "condition": "NM",
          "purchasePrice": null,
          "purchaseCurrency": null,
          "notes": "Spanish print from local shop"
        }
      ]
    }
  ]
}
```

Secondary export: CSV (Manabox-compatible for MTG cards — Phase 5).

---

## Game Mode

The app operates in one game mode at a time: **MTG** or **Pokemon**. This is a global toggle accessible from the home screen or settings.

- Simplifies UI — no need for "filter by game" everywhere
- Reduces scanner processing — hash lookup against ~50k cards instead of ~115k
- Reduces DB memory footprint — only load one game's hash index at a time
- Binders are game-specific (created under the active game mode)
- Switching mode changes which binders, search results, and scanner index are active
- Collection value on home screen reflects the active game mode (with an "all games" option in settings)

---

## UI Screens

### Phase 0 — OpenCV PoC
- Camera preview (full-screen)
- Debug overlay: detected contours, corner points, card border highlight
- Cropped/warped card image display (side panel or bottom sheet)

### Phase 1 — Card Database
- **Card Search**: text search, results show thumbnail + name + set + price
- **Card Detail**: full card image, set, rarity, type, prices (USD + EUR, regular + foil)
- **Settings**: game mode toggle (MTG / Pokemon), default currency, DB update trigger

### Phase 2 — Collection
- **Home / Binder List**: list of binders with card count + total value. FAB to create binder. Long-press to rename/delete.
- **Binder Detail**: card list (sortable by name/set/price/date). Search within binder. Total value. FAB to add card (opens search).
- **Card Detail** (updated): "Add to binder" button with quantity/language/foil pickers. If already in a binder: show which binders + edit entry.
- **Export**: JSON export from settings

### Phase 3 — Scanner
- **Scanner**: full-screen camera preview. Card border detection overlay. Bottom sheet: current match with confirm/reject/cycle editions. Session summary via swipe-up. Settings gear: quick mode toggle, set lock.

### Phase 4 — Price Tracking
- **Card Detail** (updated): price history sparkline/chart, gain/loss vs purchase price
- **Home** (updated): collection value trend indicator
- **Insights screen**: collection value over time chart, most valuable cards, biggest movers

### Phase 5 — Polish
- **Collector Mode**: set completion grid (owned vs missing)
- **Wishlist**: separate list view
- **Bulk Edit**: multi-select → batch edit properties
- **Import**: CSV import flow with preview + error handling

### Settings (all phases, grows over time)
- Game mode toggle (MTG / Pokemon)
- Default currency (USD / EUR)
- Default language for new cards
- Price source preference
- Card database update (manual trigger)
- Export collection (JSON, later CSV)
- About / version

---

## Key Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Perceptual hashing fails on foil/holo cards | Users can't scan a large portion of their collection | Art-crop region (avoid holo border); multi-frame voting; OCR fallback (Phase 7) |
| TCGdex API goes down or changes | Pokemon data unavailable | Ship full snapshot in the DB; TCGdex is open-source and self-hostable as fallback |
| OpenCV contour detection fails on busy backgrounds | Card not detected | Require white/clean background (same as Manabox); show user guidance overlay |
| Scryfall rate limiting during DB build pipeline | Can't rebuild card DB | Use bulk data downloads (JSON dumps); only use API for delta updates. Build DB in CI, not on-device |
| Same artwork across multiple MTG printings | Wrong edition matched | Show edition picker in confirmation UI; set-locking feature |
| Hash collisions between visually similar cards | Misidentification | Use RGB phash (3-channel) instead of grayscale; lower hamming threshold; show top-3 candidates |
| OpenCV native library size on Android | Large APK | `opencv_dart` v2.2.0+ compiles only enabled modules. With `imgproc` + `img_hash` only: ~15-20MB .so. Total APK ~80-100MB (Manabox is 104MB) |
| `opencv_dart` first build time | Slow dev setup | OpenCV compiles from source via CMake on first build. Document in README, one-time cost |

---

## Resolved Decisions

| Question | Decision | Rationale |
|---|---|---|
| State management | Riverpod v3.x | Dart-idiomatic, `StreamProvider` maps directly to Drift reactive queries, minimal boilerplate for small team |
| OpenCV integration | `opencv_dart` v2.2.1+ | Actively maintained (Feb 2026), full OpenCV 4.13, async API, `img_hash` module for PHash. Manabox uses custom FFI but we don't need that complexity |
| Database | Drift (not raw sqflite) | Type-safe queries, compile-time checked SQL, built-in migration support, DAO pattern, reactive streams |
| Encryption | Not needed (plain SQLite) | Hobby project. Can add SQLCipher later if commercializing |
| Min Android API | 26 (Android 8.0) | 95%+ device coverage, simplifies some APIs |
| Target devices | Pixel 8a, Pixel 10 Pro | Both arm64-v8a, full CameraX support, 8-16GB RAM |
| Distribution | Side-loaded APK | Low friction, `flutter build apk --split-per-abi` |
| Hash type | OpenCV PHash (single) | Start simple. Add aHash/dHash if accuracy insufficient |
| MTG reprints | Edition picker + set locking | Show all matching editions, default to most recent, user picks. Set-lock for bulk scanning |
| Price refresh | Daily for collection, on-demand per card | Scryfall stale after 24h. TCGdex unknown but similar |
| Camera format | NV21 on Android | Most efficient for OpenCV conversion — avoids 3-plane YUV complexity |
| Frame processing | `opencv_dart` async API + frame dropping | Skip frames during processing to maintain preview smoothness |
| Project structure | Feature-first UI, type-first data layer | Flutter team recommendation (Compass App pattern) |
| Backup | Not needed | Export to JSON is sufficient. No cloud backup |
| Art crop coordinates | Measured (see Art Crop Reference) | MTG 2015 frame as default, Pokemon SV/SM as default |
| Card images | Download per-set, stored locally | Enables offline browsing + scanning. User picks which sets to download |
| API usage | Non-commercial, educational | Firefox user agent, respectful rate limiting |

## Open Questions

1. **Hamming distance threshold?** What's the right cutoff for "match" vs "no match"? Need empirical testing with the test corpus in Phase 6. Start with ≤10 bits, measure false positive/negative rates, tune.

2. **Full-art / borderless card handling?** Full-art MTG cards and Pokemon V/VMAX/ex cards have art that fills the entire card. The standard art crop rect won't work. Options:
   - Detect full-art cards (by checking if the standard art-box border colors are absent) and switch to a larger crop
   - Hash the full card image as fallback when art-crop hash has no good match
   - TBD — test during Phase 3

3. **`opencv_dart` first build time?** v2.2.0+ compiles OpenCV from source via CMake (only enabled modules: `imgproc` + `img_hash`). One-time cost, cached after that. Need to measure and document in README.

### API Usage

This is a **non-commercial, educational project** (learning to program with my son).

| API | Terms | User-Agent | Image Storage |
|---|---|---|---|
| Scryfall | Free for non-commercial use. Requires `User-Agent` header, 50-100ms between requests. | `Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0` | Download art crops for sets we plan to scan. Store locally in app data. |
| TCGdex | MIT licensed, open source. No documented rate limits. | Same Firefox UA | Download card images per set. Store locally. |

**Local image storage strategy:**
- User selects specific sets to download (e.g., "Scarlet & Violet 151", "Modern Horizons 3")
- App downloads all card images for that set to local storage
- Images used for both display (no network needed after download) and hash index building
- Settings screen shows downloaded sets + storage used, with option to delete
- This also enables fully offline browsing/scanning for downloaded sets

---

## Project Structure

> Hybrid: feature-first for UI, type-first for data. MVVM pattern per Flutter team recommendation.

```
manab/
├── lib/
│   ├── main.dart
│   │
│   ├── config/
│   │   ├── app_config.dart              # Environment config
│   │   ├── di.dart                      # Riverpod provider overrides
│   │   └── router.dart                  # go_router setup
│   │
│   ├── domain/                          # Pure models — no Flutter imports
│   │   ├── card.dart
│   │   ├── card_entry.dart
│   │   ├── binder.dart
│   │   ├── card_hash.dart
│   │   ├── price_record.dart
│   │   └── game_mode.dart               # Enum: mtg | pokemon
│   │
│   ├── data/                            # Type-first: repositories + services + DB
│   │   ├── database/
│   │   │   ├── app_database.dart        # Drift @DriftDatabase
│   │   │   ├── tables/                  # Drift table definitions
│   │   │   │   ├── cards_table.dart
│   │   │   │   ├── binders_table.dart
│   │   │   │   ├── card_entries_table.dart
│   │   │   │   └── card_hashes_table.dart
│   │   │   ├── daos/                    # Data access objects
│   │   │   │   ├── cards_dao.dart
│   │   │   │   ├── binders_dao.dart
│   │   │   │   ├── card_entries_dao.dart
│   │   │   │   └── card_hashes_dao.dart
│   │   │   └── migrations/
│   │   │       └── migration_v1_to_v2.dart
│   │   │
│   │   ├── repositories/               # Abstract interface + impl
│   │   │   ├── card_repository.dart
│   │   │   ├── binder_repository.dart
│   │   │   ├── price_repository.dart
│   │   │   └── scanner_repository.dart
│   │   │
│   │   └── services/
│   │       ├── scryfall_api_service.dart
│   │       ├── tcgdex_api_service.dart
│   │       ├── scanner_service.dart     # Wraps opencv_dart calls
│   │       ├── export_service.dart
│   │       └── import_service.dart
│   │
│   └── ui/                              # Feature-first
│       ├── core/                        # Shared widgets + themes
│       │   ├── theme/
│       │   └── widgets/
│       ├── card_browser/                # Search + card detail
│       │   ├── card_browser_screen.dart
│       │   ├── card_browser_view_model.dart
│       │   └── widgets/
│       ├── collection/                  # Binders + card entries
│       │   ├── collection_screen.dart
│       │   ├── binder_detail_screen.dart
│       │   └── widgets/
│       ├── scanner/                     # Camera + recognition
│       │   ├── scanner_screen.dart
│       │   ├── scanner_view_model.dart
│       │   └── widgets/
│       ├── prices/                      # Price tracking + charts
│       └── settings/
│
├── test/                                # Mirrors lib/ structure
│   ├── data/repositories/
│   ├── data/services/
│   ├── domain/
│   └── ui/
│
├── integration_test/                    # On-device tests
│
├── testing/                             # Fakes + fixtures (shared by test/ and integration_test/)
│   ├── fakes/
│   └── fixtures/
│
├── tool/                                # Build scripts (not shipped)
│   ├── build_card_db.dart
│   ├── scryfall_client.dart
│   ├── tcgdex_client.dart
│   ├── phash_computer.dart
│   └── db_packer.dart
│
├── assets/
│   └── cards.db                         # Pre-built card DB (generated by tool/)
│
└── pubspec.yaml
```

### Camera Processing Pipeline (implementation detail)

```dart
// Scanner service pseudocode — runs per camera frame
bool _isProcessing = false;

void onCameraFrame(CameraImage image) async {
  if (_isProcessing) return;          // drop frame if busy
  _isProcessing = true;
  try {
    // 1. NV21 → BGR Mat
    final mat = cv.Mat.fromList(h, w, cv.MatType.CV_8UC1, nv21bytes);
    final bgr = await cv.cvtColorAsync(mat, cv.COLOR_YUV2BGR_NV21);

    // 2. Downsample for detection (480px wide)
    final small = await cv.resizeAsync(bgr, (480, 0));

    // 3. Edge detection
    final gray = await cv.cvtColorAsync(small, cv.COLOR_BGR2GRAY);
    final blur = await cv.gaussianBlurAsync(gray, (5, 5), 0);
    final edges = await cv.cannyAsync(blur, 50, 150);

    // 4. Find card contour (largest quadrilateral)
    final contours = await cv.findContoursAsync(edges, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);
    final card = findBestQuadrilateral(contours);
    if (card == null) return;

    // 5. Perspective warp → standard card size per game
    final size = activeGameMode == GameMode.mtg ? Size(672, 936) : Size(734, 1024);
    final warped = await warpToCard(bgr, card.corners, size);

    // 6. Crop art region → PHash
    final artCrop = cropArtRegion(warped, activeGameMode);
    final hasher = cv.PHash.create();
    final hash = hasher.compute(artCrop);

    // 7. Lookup in DB
    final candidates = await cardHashesDao.findByHammingDistance(hash, threshold: 10);
    emit(ScanResult(candidates));
  } finally {
    _isProcessing = false;
  }
}
```

---

## Appendix: Manabox APK Analysis

> Reverse-engineered from APK downloaded 2026-03-10, version ~3.27.x.

| Finding | Detail |
|---|---|
| Framework | Flutter (Dart) — confirmed by `assets/flutter_assets/` |
| Camera | `camera_android_camerax` plugin |
| Computer vision | `native_opencv` — Flutter plugin wrapping OpenCV via FFI |
| Card matching | `imagematch` module referenced in DEX strings |
| Custom logic | `manabox_plugin` (package: `skilldevs.com.manabox_plugin`) |
| Card database | `cards.db` — 78MB encrypted SQLite via `sqlcipher_flutter_libs` (entropy: 7.98/8.0 bits/byte) |
| ML models | **None** — zero `.tflite`, `.onnx`, `.pb` files in APK |
| Audio | `just_audio` + `audio_session` |
| Payments | RevenueCat (`purchases_flutter`) + Google Ads |
| Auth | Firebase Auth + Google Sign-In + Apple Sign-In |
| Error tracking | Sentry (`sentry_flutter`) |
| APK size | 104 MB (base split, no native .so — delivered via Play Store split APKs) |
