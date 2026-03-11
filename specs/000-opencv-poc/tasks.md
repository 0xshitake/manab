# Tasks: Project Scaffold + OpenCV Proof of Concept

**Input**: Design documents from `/specs/000-opencv-poc/`
**Prerequisites**: plan.md (required), spec.md (required)

---

## Phase 1: Project Scaffold

**Goal**: Initialize the Flutter project with all core dependencies and folder structure.

- [x] T001 Create Flutter project with `flutter create manab`, set `minSdkVersion 26`, `targetSdkVersion 35`, enable only Android platform (`pubspec.yaml`, `android/app/build.gradle`)
- [x] T002 Configure `pubspec.yaml` with dependencies: `opencv_dart: ^2.2.1`, `camera`, `flutter_riverpod`, `drift`, `sqlite3_flutter_libs`, `go_router`, `dio`, `cached_network_image`, `uuid` (`pubspec.yaml`)
- [x] T003 Create folder structure: `lib/{config,domain,data,ui}` with subdirectories per architecture spec (`lib/`)
- [x] T004 Create `lib/config/app_config.dart` with environment config stub (`lib/config/app_config.dart`)
- [x] T005 [P] Create `lib/config/di.dart` with Riverpod provider overrides scaffold (`lib/config/di.dart`)
- [x] T006 [P] Create `lib/config/router.dart` with go_router setup — single route: scanner screen (`lib/config/router.dart`)
- [x] T007 [P] Create `lib/domain/game_mode.dart` with `GameMode` enum: `mtg`, `pokemon` (`lib/domain/game_mode.dart`)
- [x] T008 Create `lib/main.dart` with `ProviderScope`, `MaterialApp.router`, launch scanner screen (`lib/main.dart`)

---

## Phase 2: Camera Setup

**Goal**: Get a live camera preview running on-device with NV21 frame access.

- [x] T009 Create `lib/ui/scanner/scanner_screen.dart` with full-screen `CameraPreview` widget, initialize front camera with `ImageFormatGroup.nv21` (`lib/ui/scanner/scanner_screen.dart`)
- [x] T010 Create `lib/ui/scanner/scanner_view_model.dart` with Riverpod notifier managing camera lifecycle (init, dispose, frame stream) (`lib/ui/scanner/scanner_view_model.dart`)
- [ ] T011 Verify camera preview works on Pixel 8a — confirm NV21 frames are received in `onImageAvailable` callback

---

## Phase 3: OpenCV Card Detection

**Goal**: Detect card borders in camera frames using OpenCV contour detection.

- [x] T012 Create `lib/data/services/scanner_service.dart` with `detectCard(Uint8List nv21, int width, int height)` method returning corner points or null (`lib/data/services/scanner_service.dart`)
- [x] T013 Implement NV21 → BGR Mat conversion using `cv.Mat.fromList` + `cv.cvtColorAsync` (`lib/data/services/scanner_service.dart`)
- [x] T014 Implement detection pipeline: downsample to 480px → grayscale → Gaussian blur (5,5) → Canny (50,150) → `findContoursAsync` → filter for largest quadrilateral with ~63:88 aspect ratio (`lib/data/services/scanner_service.dart`)
- [x] T015 Implement frame dropping: `_isProcessing` guard to skip frames while detection is running (`lib/data/services/scanner_service.dart`)
- [x] T016 Create `lib/ui/scanner/widgets/card_border_overlay.dart` — `CustomPainter` that draws detected contour corners and border highlight on camera preview (`lib/ui/scanner/widgets/card_border_overlay.dart`)

---

## Phase 4: Perspective Warp

**Goal**: Correct perspective and normalize detected card to standard dimensions.

- [x] T017 Implement corner ordering: sort 4 detected corners into [top-left, top-right, bottom-right, bottom-left] order (`lib/data/services/scanner_service.dart`)
- [x] T018 Implement `warpCard(Mat bgr, List<Point> corners, Size targetSize)`: `cv.getPerspectiveTransform` + `cv.warpPerspectiveAsync` → output normalized card image at MTG 672×936 or Pokemon 734×1024 (`lib/data/services/scanner_service.dart`)
- [x] T019 Create `lib/ui/scanner/widgets/cropped_card_display.dart` — bottom sheet or overlay showing the warped card image (`lib/ui/scanner/widgets/cropped_card_display.dart`)
- [x] T020 Wire up full pipeline in scanner view model: frame → detect → warp → display cropped image (`lib/ui/scanner/scanner_view_model.dart`)

---

## Phase 5: Verification

**Goal**: Confirm the PoC works reliably on target hardware with real cards.

- [ ] T021 Test with 5+ MTG cards on white background — verify border detection highlights correctly on Pixel 8a
- [ ] T022 Test with 5+ MTG cards on white background — verify perspective warp produces clean cropped images
- [ ] T023 Measure end-to-end latency (frame → detection → warp → display) — target <100ms
- [ ] T024 Test edge cases: angled cards (±15°), partially visible cards, no card in frame — verify graceful handling
- [ ] T025 Build release APK (`flutter build apk --split-per-abi`) and verify it installs and runs on Pixel 8a via `adb install`
- [ ] T026 Document `opencv_dart` first build time in README
