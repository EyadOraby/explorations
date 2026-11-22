import 'package:material_ui/material_ui.dart';

/// One small, self-contained experiment: a question, a working demo and
/// what I took away from it.
class Experiment {
  const Experiment({
    required this.slug,
    required this.title,
    required this.question,
    required this.notes,
    required this.started,
    required this.builder,
  });

  /// Used in the URL: `?e=<slug>` opens the experiment directly on the web.
  final String slug;
  final String title;

  /// What I wanted to find out.
  final String question;

  /// What I learned, one finding per line.
  final List<String> notes;

  /// When the experiment started, as `YYYY-MM-DD`.
  final String started;

  final WidgetBuilder builder;
}
