import 'package:material_ui/material_ui.dart';

import 'experiment.dart';
import 'gallery_page.dart';
import 'theme.dart';

/// The demo on top, then the question and what I learned.
class ExperimentPage extends StatelessWidget {
  const ExperimentPage({super.key, required this.experiment});

  final Experiment experiment;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            final nav = Navigator.of(context);
            if (nav.canPop()) {
              nav.pop();
            } else {
              nav.pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const GalleryPage()),
              );
            }
          },
        ),
        title: Text(experiment.title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Material(
                    color: card,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: rule),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: experiment.builder(context),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'The question',
                    style: text.labelLarge?.copyWith(color: muted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    experiment.question,
                    style: text.titleMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'What I learned',
                    style: text.labelLarge?.copyWith(color: muted),
                  ),
                  const SizedBox(height: 6),
                  for (final note in experiment.notes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsetsDirectional.only(
                              top: 9,
                              end: 10,
                            ),
                            child: SizedBox.square(
                              dimension: 5,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              note,
                              style: text.bodyLarge?.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
