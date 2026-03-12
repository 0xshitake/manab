# Manab — TCG Collection Manager

Android app for managing Magic: The Gathering and Pokemon TCG card collections with camera-based card recognition and price tracking.

## Stack

- **Flutter 3.38+** / Dart 3.10+
- **Camera**: `camera` plugin (CameraX, NV21 format)
- **CV**: `opencv_dart` v2.2.1+ (modules: `imgproc`, `img_hash`)
- **DB**: Drift (type-safe SQLite)
- **State**: Riverpod v3.x
- **Routing**: go_router
- **HTTP**: dio
- **Min SDK**: Android API 26 (arm64-v8a only)

## Project Structure

Feature-first UI, type-first data. MVVM pattern.

```
lib/
  config/         # app_config, di (providers), router
  domain/         # Pure models — no Flutter imports
  data/
    database/     # Drift tables, DAOs, migrations
    repositories/ # Abstract + impl
    services/     # API clients, scanner, import/export
  ui/
    core/         # Shared widgets + theme
    <feature>/    # screen, view_model, widgets/
test/             # Mirrors lib/
integration_test/ # On-device tests
testing/          # Fakes + fixtures
tool/             # Build scripts (not shipped)
```

## Conventions

- Riverpod providers in `config/di.dart`; feature-specific providers colocated with view models
- Drift DAOs return `Stream<List<T>>` for reactive UI
- Domain models are plain Dart — no Flutter or Drift imports
- One Drift migration file per schema version bump: `migration_vN_to_vN+1.dart`
- API calls use Firefox UA: `Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0`

## Releases

- CI builds APK on every push to master; creates a GitHub Release only on `v*` tags
- GitHub Actions minutes are unlimited for public repos — no need to conserve builds
- Always create a new tag for each release; never move/override existing tags

## Specs

Each phase lives in `specs/NNN-name/` with `spec.md`, `plan.md`, `tasks.md`. Read all three before implementing. Mark tasks `[x]` in tasks.md as you complete them.
