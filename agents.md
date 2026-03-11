# Agent Guidelines

## Before starting

1. Read the three files for your assigned spec: `spec.md`, `plan.md`, `tasks.md`
2. Read `CLAUDE.md` for stack and conventions
3. Work on branch `NNN-spec-name` (e.g., `000-opencv-poc`)

## While working

- Follow task order in `tasks.md` — phases are sequential, `[P]` tasks within a phase can be parallelized
- Mark each task `[x]` when done
- Don't modify files outside your spec's scope unless `plan.md` lists them under "modified files"
- Don't add dependencies not listed in `plan.md`
- Don't create docs, READMEs, or comments beyond what the task requires
- Run `flutter analyze` after code changes — fix all warnings before moving on
- Skip tasks requiring physical hardware — mark `[ ]` with `# requires device`

## Code style

- No orphan files — every new file must be imported/used somewhere
- Prefer `async/await` over raw Futures
- Name files `snake_case.dart`, classes `PascalCase`, variables `camelCase`
- Keep widgets in `widgets/` subdirectory under their feature
- Tests mirror `lib/` path: `lib/data/daos/foo.dart` → `test/data/daos/foo_test.dart`
