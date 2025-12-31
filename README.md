## Melos example workspace

This repository is a simple Melos-powered Flutter monorepo.

### Structure

- **apps/main_app**: main Flutter application.
- **apps/sub_app**: secondary Flutter application.
- **packages/shared**: shared Dart package used by both apps.

### Melos

Melos is configured via `melos.yaml` at the repository root:

- **packages**: `apps/*`, `packages/*`
- **scripts**:
  - `pub:get`: `melos exec -- flutter pub get`
  - `analyze`: `melos exec -- flutter analyze`

To use Melos, install it (if you haven't already):

```bash
dart pub global activate melos
```

Then, from the repository root:

```bash
melos bootstrap   # links local packages together
melos run pub:get
melos run analyze
```

### Running the apps

From the repository root:

```bash
cd apps/main_app
flutter run
```

or:

```bash
cd apps/sub_app
flutter run
```


