# Explorations

Small Flutter experiments: animation, right-to-left layouts and accessibility.
Each one starts with a question, ships a working demo and ends with what I learned.

**Live demo:** https://eyadoraby.github.io/explorations/

## Experiments

| # | Experiment | Question | Started |
|---|------------|----------|---------|

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
