import 'experiment.dart';
import 'experiments/rtl/rtl.dart';
import 'experiments/stagger/stagger.dart';

/// Every experiment, oldest first. Each lives in `lib/experiments/<slug>/`.
final List<Experiment> experiments = [staggerExperiment, rtlExperiment];

Experiment? experimentBySlug(String? slug) {
  for (final e in experiments) {
    if (e.slug == slug) return e;
  }
  return null;
}
