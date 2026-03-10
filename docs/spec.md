# Manab — TCG Collection Manager

## Overview

Android application for managing Magic: The Gathering and Pokemon TCG card collections with camera-based card recognition and price tracking. Local-first, no account required.

**Name:** Manab (working title)
**Platform:** Android (Kotlin + Jetpack Compose)
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
- iOS or web versions
- Card condition grading via camera
- Marketplace integration (buying/selling)

---

## Phase Plan

### Phase 1 — Manual Collection + Data Foundation
> Get the boring but essential stuff working first.

- Card database browser (search by name, set, type)
- Manual card entry (search → add to binder)
- Binder management (create, rename, delete)
- Per-card metadata: quantity, language, foil/non-foil, notes
- Price display per card (fetched from APIs)
- Collection value summary per binder and total
- Data persistence (local SQLite via Room)
- Export to JSON

### Phase 2 — Card Scanner (MVP)
> The hard part. Camera-based card recognition.

- Camera preview with real-time card border detection
- Card detection using YOLO Nano OBB (TFLite on-device)
- Card identification using perceptual hashing (artwork matching)
- Pre-built hash index for all Pokemon + MTG cards
- Match confirmation UI (show top match + alternatives)
- Quick mode (auto-confirm) vs manual mode
- Session-based scanning (scan batch → review → commit to binder)
- Set locking to narrow match scope

### Phase 3 — Polish + Advanced Features
> Make it actually pleasant to use daily.

- Price history graphs per card
- Collection value over time chart
- Bulk edit (select multiple cards → change language/condition/etc.)
- Collector mode (set completion tracking — owned vs missing grid)
- Wishlist / want list
- Import from CSV (Manabox-compatible format)
- Export to CSV (Manabox-compatible format)
- Barcode/QR scanning for sealed products (set identification)
- Audio feedback during scanning (price tier tones)
- Widget for collection value on home screen

### Phase 4 — Future / Nice-to-Have

- Multi-language card name search (search Spanish name, find English card)
- OCR fallback for cards that fail hash matching
- Foil detection heuristics (multi-frame voting)
- Companion web viewer (read-only, export-based)
- Share binder as link (static HTML export)

---

## Technical Architecture

### Tech Stack

| Layer | Choice | Rationale |
|---|---|---|
| Language | Kotlin | Native Android, best camera/ML perf |
| UI | Jetpack Compose | Modern, declarative, well-supported |
| Database | Room (SQLite) | Local-first, offline, no backend needed |
| Camera | CameraX | Standard Android camera lib, ML Kit integration |
| Card detection | YOLO Nano OBB via TFLite | ~6MB model, real-time on-device card localization |
| Card identification | Perceptual hashing (RGB phash) | No ML runtime needed for matching, scales to 100k+ cards |
| Image processing | OpenCV Android SDK | Perspective correction, normalization after detection |
| Networking | Ktor or Retrofit | API calls for card data + prices |
| DI | Hilt | Standard for Android |
| Image loading | Coil | Kotlin-first, Compose-native |

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

```
Camera Frame
    │
    ▼
┌──────────────────────┐
│ 1. Card Detection     │  YOLO Nano OBB (TFLite)
│    - Locate card in   │  Input: camera frame (416×416)
│      frame            │  Output: oriented bounding box
│    - Handle rotation  │  Model size: ~6MB
└──────────┬───────────┘
           │ cropped card region
           ▼
┌──────────────────────┐
│ 2. Perspective Warp   │  OpenCV
│    - Correct skew     │  Transform to standard
│    - Normalize to     │  card dimensions (488×680)
│      standard size    │
└──────────┬───────────┘
           │ normalized card image
           ▼
┌──────────────────────┐
│ 3. Art Region Crop    │  Fixed crop ratios per game
│    - Extract artwork  │  MTG: known art box position
│      area only        │  Pokemon: known art box position
│    - Ignore borders,  │  Reduces foil interference
│      text, holo       │
└──────────┬───────────┘
           │ art crop
           ▼
┌──────────────────────┐
│ 4. Perceptual Hash    │  Custom implementation
│    - Resize to 32×32  │  RGB variant (3-channel)
│    - DCT transform    │  Output: 64-bit hash
│    - Generate phash   │
└──────────┬───────────┘
           │ 64-bit hash
           ▼
┌──────────────────────┐
│ 5. Index Lookup       │  In-memory hash table
│    - Hamming distance │  Threshold: ≤10 bits difference
│      against all      │  Set-lock filter applied first
│      stored hashes    │  Returns top-N candidates
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

### Hash Index Build Process (offline/on first launch)

1. Download card images from TCGdex (Pokemon) and Scryfall (MTG) art crops
2. For each card image:
   - Crop to art region (if using full card image)
   - Resize to 32×32
   - Compute RGB perceptual hash (64-bit)
3. Store as `cardId → phash` mapping
4. Ship pre-built index with the APK (~2-3MB for all games combined)
5. Delta updates when new sets release

**Index size estimates:**
- Pokemon: ~15,000 cards × 8 bytes = ~120 KB
- MTG (unique artworks): ~50,000 × 8 bytes = ~400 KB
- MTG (all printings): ~100,000 × 8 bytes = ~800 KB
- Total with metadata: ~2-3 MB

### Language Support

| Feature | English | Spanish | Other |
|---|---|---|---|
| Card search | Yes | Yes | No (Phase 4) |
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

Secondary export: CSV (Manabox-compatible for MTG cards — Phase 3).

---

## UI Screens (Phase 1)

### Home / Binder List
- List of binders with card count and total value each
- Total collection value banner at top
- FAB to create new binder
- Long-press to rename/delete binder

### Binder Detail
- Card list (sortable by: name, set, price, date added)
- Filter by game (MTG / Pokemon / All)
- Search within binder
- Total binder value
- FAB to add card (opens search)

### Card Search
- Text search across cached card DB
- Toggle: MTG / Pokemon / All
- Results show: card image thumbnail, name, set, price
- Tap to view card detail → add to binder

### Card Detail
- Full card image
- Card metadata (set, rarity, type, etc.)
- Price info (USD + EUR, regular + foil)
- "Add to binder" button with quantity/language/foil pickers
- If already in a binder: show which binders + edit entry

### Scanner (Phase 2)
- Full-screen camera preview
- Card border detection overlay
- Bottom sheet: current match with confirm/reject/cycle
- Session summary accessible via swipe-up
- Settings gear: quick mode toggle, set lock, game filter

### Settings
- Default currency (USD / EUR)
- Default language for new cards
- Price source preference
- Card database update (manual trigger)
- Export collection
- About / version

---

## Key Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Perceptual hashing fails on foil/holo cards | Users can't scan a large portion of their collection | Art-crop region (avoid holo border); multi-frame voting; OCR fallback (Phase 4) |
| TCGdex API goes down or changes | Pokemon data unavailable | Cache aggressively; consider shipping a snapshot with the APK |
| YOLO model too large/slow on budget phones | Poor scanning UX | Start with YOLO Nano (~6MB); benchmark on target device early |
| Scryfall rate limiting during initial DB build | Slow first launch | Use bulk data downloads (JSON dumps); only use API for delta updates |
| Same artwork across multiple MTG printings | Wrong edition matched | Show edition picker in confirmation UI; set-locking feature |
| Hash collisions between visually similar cards | Misidentification | Use RGB phash (3-channel) instead of grayscale; lower hamming threshold; show top-3 candidates |

---

## Open Questions

1. **Ship hash index in APK vs build on first launch?** Shipping is faster UX but increases APK size by ~3MB. Building on-device requires downloading all card art crops (~several GB).
   - **Recommendation:** Ship pre-built index in APK. Update via small delta downloads.

2. **Single hash type vs multi-hash?** The NolanAmblard project uses 4 hash types (average, wavelet, perceptual, difference) for better accuracy.
   - **Recommendation:** Start with RGB phash only. Add additional hash types if accuracy is insufficient.

3. **How to handle MTG reprints with identical artwork?** Many MTG cards share artwork across sets — phash will match them all equally.
   - **Recommendation:** Return all matching editions, default to the most recent printing, let user pick the correct one. Set-locking solves this for bulk scanning of a known set.

4. **Price refresh frequency?** Scryfall prices are stale after 24h. TCGdex unclear.
   - **Recommendation:** Refresh prices daily for cards in collection. On-demand refresh when viewing a specific card.

5. **Target minimum Android version?** Manabox targets API 24 (Android 7.1).
   - **Recommendation:** API 26 (Android 8.0) — covers 95%+ of active devices, simplifies some APIs.

6. **YOLO model: pre-trained or custom?** The 1vcian project trained on 10k synthetic card images.
   - **Recommendation:** Start with a pre-trained YOLO Nano for general object detection. Fine-tune on card images if needed. Alternatively, use OpenCV contour detection for Phase 2 MVP (simpler, no ML model needed) and upgrade to YOLO later.
