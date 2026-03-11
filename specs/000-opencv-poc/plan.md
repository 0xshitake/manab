# Implementation Plan: Project Scaffold + OpenCV Proof of Concept

**Branch**: `000-opencv-poc` | **Date**: 2026-03-10 | **Spec**: [spec.md](./spec.md)

## Summary

Set up the Flutter project with all dependencies configured, then prove the hardest tech risk: real-time card border detection and perspective correction using OpenCV on the phone camera. This is the foundation — everything else depends on it.

## Technical Context

**Language/Version**: Dart 3.10+, Flutter 3.38+
**Primary Dependencies**: `opencv_dart` v2.2.1+, `camera` plugin (CameraX backend), `riverpod`, `drift`, `go_router`
**Storage**: N/A (no persistent data yet)
**Testing**: Manual on-device testing with real cards
**Target Platform**: Android (arm64-v8a) — Pixel 8a, Pixel 10 Pro
**Project Type**: Flutter mobile app
**Performance Goals**: Card detection + crop in <100ms per frame
**Constraints**: `opencv_dart` compiles OpenCV from source on first build (one-time cost); requires white/clean background for reliable detection
**Scale/Scope**: ~15 files to create, 1 screen (camera preview + debug overlay)

## Project Structure

### Documentation (this feature)

```text
specs/000-opencv-poc/
  spec.md
  plan.md
  tasks.md
```

### Source Code

```text
manab/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── di.dart
│   │   └── router.dart
│   ├── domain/
│   │   └── game_mode.dart
│   ├── data/
│   │   └── services/
│   │       └── scanner_service.dart      # OpenCV card detection + warp
│   └── ui/
│       └── scanner/
│           ├── scanner_screen.dart        # Camera preview + debug overlay
│           ├── scanner_view_model.dart
│           └── widgets/
│               ├── card_border_overlay.dart
│               └── cropped_card_display.dart
├── pubspec.yaml
└── android/
    └── app/build.gradle                   # arm64-v8a, minSdk 26
```

## Key Decisions

| Decision | Rationale |
| -------- | --------- |
| `opencv_dart` v2.2.1+ | Full OpenCV 4.13 via dart:ffi, async API, `img_hash` module for later PHash. Actively maintained. |
| Camera NV21 format | Most efficient for OpenCV conversion on Android — single plane, avoids YUV complexity |
| Downsample to 480px for detection | Full resolution unnecessary for contour detection; saves processing time |
| Frame dropping strategy | Skip frames while processing to maintain smooth camera preview |
| Card aspect ratio ~63:88 | Standard MTG/Pokemon card ratio, used to filter detected quadrilaterals |
| Two output sizes | MTG: 672×936, Pokemon: 734×1024 — match Scryfall/TCGdex image dimensions |

## Downstream Dependencies

This milestone exposes the following for downstream specs:
- **Scanner service**: Card detection + perspective warp reused in Phase 3 scanner
- **Camera infrastructure**: CameraX setup, frame processing loop, NV21 conversion
- **Project scaffold**: Folder structure, dependency configuration, Riverpod/Drift/go_router setup
- **Debug overlay**: Contour visualization reusable for scanner UI

## Complexity Tracking

Primary risk: `opencv_dart` first build time (compiles OpenCV from source). One-time cost, cached after. Need to measure and document.

Secondary risk: Contour detection reliability on varied backgrounds. Mitigation: require white background (same as Manabox).
