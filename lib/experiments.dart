import 'experiment.dart';

/// Every experiment, oldest first. Each lives in `lib/experiments/<slug>/`.
final List<Experiment> experiments = [];

Experiment? experimentBySlug(String? slug) {
  for (final e in experiments) {
    if (e.slug == slug) return e;
  }
  return null;
}
