---
feature: "Project Scaffold + OpenCV Proof of Concept"
status: draft
tier: complex
created: 2026-03-10
depends_on: []
---

# 000 - Project Scaffold + OpenCV Proof of Concept

## Summary

Prove the hardest tech risk before building anything else. Set up the Flutter project and integrate OpenCV for real-time card border detection and perspective correction from the phone camera.

## User Stories

### US-001: Developer can build and run the app (Priority: P0)

**As a** developer
**I want** a properly scaffolded Flutter project
**So that** I can build and deploy to my Pixel 8a/10 Pro

**Acceptance Criteria:**
- GIVEN a fresh checkout WHEN I run `flutter build apk --split-per-abi` THEN it produces an arm64 APK
- GIVEN the APK WHEN I install via `adb install` THEN it launches without crashing
- GIVEN the project WHEN I check dependencies THEN `opencv_dart`, `camera`, `riverpod`, `drift`, `go_router` are configured

### US-002: Camera detects and crops a card (Priority: P0)

**As a** user
**I want** to point my phone camera at a card on a white background
**So that** the app detects the card borders and shows me a cropped, normalized image

**Acceptance Criteria:**
- GIVEN camera preview is active WHEN a card is placed on a white background THEN the app highlights the detected card border
- GIVEN a detected card WHEN the perspective warp runs THEN a cropped image is displayed at standard size (672×936 MTG / 734×1024 Pokemon)
- GIVEN the full pipeline WHEN measured end-to-end THEN card detection + crop completes in <100ms

## Tasks

- T0.1: Flutter project setup — folder structure, linting, dependencies per project structure in architecture spec
- T0.2: Camera preview screen — full-screen CameraX backend, NV21 image format
- T0.3: OpenCV integration — `opencv_dart` v2.2.1+ with `imgproc` + `img_hash` modules
- T0.4: Card border detection — grayscale → Gaussian blur → Canny edges → `findContours()` → largest quadrilateral
- T0.5: Perspective warp — `getPerspectiveTransform()` + `warpPerspective()` to standard card size
- T0.6: Debug overlay — show detected contours, corner points, card border highlight on camera preview
- T0.7: Cropped card display — show warped card image in bottom sheet or side panel
- T0.8: Test on Pixel 8a and Pixel 10 Pro with real cards on white background

## Technical Notes

- Camera format: NV21 on Android for efficient OpenCV conversion (avoids 3-plane YUV complexity)
- Frame processing: `opencv_dart` async API + frame dropping (skip frames during processing to maintain preview smoothness)
- Card aspect ratio filter: ~63:88 for quadrilateral detection
- Downsample to 480px wide for detection, full resolution for warp
- See architecture spec `docs/spec.md` for camera processing pipeline pseudocode

## Exit Criteria

App reliably detects and crops a card from camera feed in <100ms on target phones.

## Out of Scope

- Card identification / hash matching (Phase 3)
- Card database or search (Phase 1)
- Any UI beyond camera preview + debug overlay
- Pokemon-specific testing (MTG card sufficient for PoC)
