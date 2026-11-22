# Explorations

Small Flutter experiments: animation, right-to-left layouts and accessibility.
Each one starts with a question, ships a working demo and ends with what I learned.

**Live demo:** https://eyadoraby.github.io/explorations/

## Experiments

| # | Experiment | Question | Started |
|---|------------|----------|---------|
| 01 | [Staggered entrances](lib/experiments/stagger/) ([demo](https://eyadoraby.github.io/explorations/?e=stagger)) | Can one controller run a staggered list entrance, and what should it do when animations are off? | 2026-11-22 |
| 02 | [Mirroring a layout for Arabic](lib/experiments/rtl/) ([demo](https://eyadoraby.github.io/explorations/?e=rtl)) | Which parts of a layout flip on their own in Arabic, and which only flip if I write them the right way? | 2026-11-22 |

## How it is organised

- `lib/experiments/<slug>/`: one folder per experiment, with its own widgets and logic
- `lib/experiments.dart`: the list the gallery shows
- `test/`: every experiment opens without errors; pure logic gets its own unit tests
- CI checks formatting, analysis and tests on every pull request, then deploys the web demo from `main`

Open one experiment directly with `?e=<slug>`, for example `https://eyadoraby.github.io/explorations/?e=stagger`.

## Run it

```sh
flutter pub get
flutter run -d chrome
```

MIT licence.
