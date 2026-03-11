# Implementation Plan: Future / Nice-to-Have

**Branch**: N/A | **Date**: 2026-03-10 | **Spec**: [spec.md](./spec.md)

## Summary

Post-v1.0 feature backlog. These features are not planned for implementation yet — they are captured here for prioritization when v1.0 is complete. Each item will be promoted to its own numbered spec with full plan and tasks when prioritized.

## Feature Backlog

### Multi-language card name search
**Effort**: Medium | **Value**: High for bilingual users
**Dependencies**: Requires cross-language index (name_en + name_es in CachedCard)
**Approach**: Add secondary name columns to CachedCard, search across both. TCGdex provides Spanish names natively; Scryfall provides via `lang:es` parameter.

### OCR fallback for failed hash matches
**Effort**: High | **Value**: Medium (covers damaged/obscured cards)
**Dependencies**: Requires OCR library (ML Kit, Tesseract, or similar)
**Approach**: When PHash returns no match (Hamming distance > threshold), crop the card name text region, run OCR, search by extracted name. Fallback only — not primary identification method.

### Foil detection heuristics
**Effort**: Medium | **Value**: Medium (convenience feature)
**Dependencies**: Phase 3 scanner infrastructure
**Approach**: Analyze variance across 3-5 frames of the same card region. Foil cards show high frame-to-frame color variance due to holographic reflections. Binary classifier: foil vs non-foil.

### Barcode/QR scanning for sealed products
**Effort**: Low | **Value**: Low-medium
**Dependencies**: Barcode scanning library (ML Kit barcode)
**Approach**: Scan barcode on sealed product → look up set code from UPC database → auto-enable set lock for that set.

### Companion web viewer
**Effort**: Medium | **Value**: Low
**Dependencies**: JSON export from Phase 2
**Approach**: Static HTML generator that reads exported JSON and produces a browse-able single-page HTML file. No backend needed.

### Share binder as link
**Effort**: Medium | **Value**: Low
**Dependencies**: Companion web viewer
**Approach**: Generate self-contained HTML file with embedded card data + images (base64 or CDN URLs). Share via any messaging app.

### Home screen widget
**Effort**: Low | **Value**: Medium (daily glance value)
**Dependencies**: Phase 4 price tracking
**Approach**: Android home screen widget using `home_widget` Flutter package. Shows total collection value + daily change.

### iOS release
**Effort**: Medium | **Value**: High (2x audience)
**Dependencies**: v1.0 Android stable
**Approach**: Flutter makes this mostly free. Need to adapt CameraX code to AVFoundation/AVCaptureSession, get Apple Developer account, handle App Store review requirements.

## Prioritization Criteria

When v1.0 is complete, prioritize based on:
1. **User requests** — what do actual users ask for most?
2. **Value/effort ratio** — quick wins first
3. **Platform expansion** (iOS) — doubles potential users
4. **Technical risk** — OCR and foil detection need prototyping before committing
