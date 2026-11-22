import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'experiment_page.dart';
import 'experiments.dart';
import 'gallery_page.dart';
import 'theme.dart';

void main() {
  runApp(const ExplorationsApp());
}

class ExplorationsApp extends StatelessWidget {
  const ExplorationsApp({super.key, this.initialSlug});

  /// Opens one experiment straight away (tests and `?e=` links).
  final String? initialSlug;

  @override
  Widget build(BuildContext context) {
    final slug = initialSlug ?? (kIsWeb ? Uri.base.queryParameters['e'] : null);
    final start = experimentBySlug(slug);
    return MaterialApp(
      title: 'Explorations',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: start == null
          ? const GalleryPage()
          : ExperimentPage(experiment: start),
    );
  }
}
