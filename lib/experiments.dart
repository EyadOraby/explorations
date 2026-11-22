import 'experiment.dart';
import 'experiments/fling/fling.dart';
import 'experiments/rtl/rtl.dart';
import 'experiments/stagger/stagger.dart';
import 'experiments/text_scale/text_scale.dart';

/// Every experiment, oldest first. Each lives in `lib/experiments/<slug>/`.
final List<Experiment> experiments = [
  staggerExperiment,
  rtlExperiment,
  textScaleExperiment,
  flingExperiment,
];

Experiment? experimentBySlug(String? slug) {
  for (final e in experiments) {
    if (e.slug == slug) return e;
  }
  return null;
}
