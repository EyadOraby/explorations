import 'package:material_ui/material_ui.dart';

import 'experiment.dart';
import 'experiment_page.dart';
import 'experiments.dart';
import 'theme.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
              children: [
                Text(
                  'Explorations',
                  style: text.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Small Flutter experiments by Eyad Oraby: animation, right-to-left '
                  'layouts and accessibility. Each one starts with a question and '
                  'ends with what I learned.',
                  style: text.bodyLarge?.copyWith(color: muted, height: 1.5),
                ),
                const SizedBox(height: 32),
                const Divider(),
                if (experiments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'The first experiment is on its way.',
                      style: text.bodyLarge?.copyWith(color: muted),
                    ),
                  ),
                for (final (i, e) in experiments.indexed) ...[
                  _ExperimentRow(number: i + 1, experiment: e),
                  const Divider(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExperimentRow extends StatelessWidget {
  const _ExperimentRow({required this.number, required this.experiment});

  final int number;
  final Experiment experiment;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ExperimentPage(experiment: experiment),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Text(
                number.toString().padLeft(2, '0'),
                style: text.titleMedium?.copyWith(
                  color: muted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experiment.title,
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    experiment.question,
                    style: text.bodyMedium?.copyWith(
                      color: muted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    experiment.started,
                    style: text.labelMedium?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: muted, size: 20),
          ],
        ),
      ),
    );
  }
}
