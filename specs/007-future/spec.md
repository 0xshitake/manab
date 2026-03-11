---
feature: "Future / Nice-to-Have"
status: draft
tier: complex
created: 2026-03-10
depends_on: ["006"]
---

# 007 - Future / Nice-to-Have

## Summary

Post-v1.0 features that expand capabilities but aren't required for the initial release. These are tracked here for planning purposes and may be promoted to their own specs when prioritized.

## Feature Ideas

### Multi-language card name search
Search in Spanish, find the English card (and vice versa). Requires cross-language index in the card database.

### OCR fallback for failed hash matches
When perceptual hashing fails (e.g., heavily damaged or obscured cards), fall back to OCR on the card name text to attempt identification.

### Foil detection heuristics
Use multi-frame voting to detect foil/holographic cards. Analyze frame-to-frame variation in the card's reflection pattern to distinguish foil from non-foil.

### Barcode/QR scanning for sealed products
Scan barcodes or QR codes on sealed products (booster packs, bundles) to identify the set for set-locking during scanning sessions.

### Companion web viewer
Read-only web viewer for collection data, powered by the JSON export. No backend — static HTML generation.

### Share binder as link
Export a binder as a static HTML page that can be shared via link. No server required — self-contained HTML file.

### Home screen widget
Android home screen widget showing total collection value with daily change indicator.

### iOS release
Flutter makes this low-effort once the Android version is stable. Requires Apple Developer account and adapting CameraX code to AVFoundation.

## Out of Scope for v1.0

All items in this spec. They are recorded for future consideration and will be promoted to individual specs with full user stories and acceptance criteria when prioritized.
