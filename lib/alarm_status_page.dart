import 'package:flutter/material.dart';

class AlarmStatusPage extends StatelessWidget {
  const AlarmStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, right: 28, top: 32),
      child: Stack(
        children: [
          const Center(
            child: SingleChildScrollView(
              child: StatusView(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: IconButton.filled(
                iconSize: 36,
                icon: const Icon(Icons.visibility),
                onPressed: () => {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusView extends StatelessWidget {
  const StatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SummaryCard(
          title: 'General',
          height: 200,
          indicators: const [
            SimpleIndicator(
              label: 'Sistema',
              indicator: StatusChip(
                label: 'Desactivado',
                state: StatusChipState.disabled,
              ),
            ),
            SimpleIndicator(
              label: 'Sirena',
              indicator: StatusChip(
                label: 'Apagada',
                state: StatusChipState.disabled,
              ),
            ),
          ],
          actionButton: OutlinedButton.icon(
            onPressed: () => {},
            icon: const Icon(Icons.report),
            label: const Text('Emergencia'),
          ),
        ),
        const SizedBox(height: 18),
        SummaryCard(
          title: 'Primer piso',
          height: 400,
          indicators: [
            ActionableIndicator(
              label: 'Puerta principal',
              indicator: const StatusChipLight(state: StatusChipState.warning),
              action: IconButton(
                onPressed: () => {},
                icon: const Icon(Icons.visibility),
              ),
            )
          ],
          actionButton: TextButton.icon(
            onPressed: () => {},
            icon: const Icon(Icons.visibility),
            label: const Text('Vigilar solo aquí'),
          ),
        ),
        const SizedBox(height: 12),
        SummaryCard(
          title: 'Segundo piso',
          height: 400,
          indicators: const [],
          actionButton: TextButton.icon(
            onPressed: () => {},
            icon: const Icon(Icons.visibility),
            label: const Text('Vigilar solo aquí'),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.height,
    required this.indicators,
    this.actionButton,
  });

  final String title;
  final double height;
  final List<Widget> indicators;
  final Widget? actionButton;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: height,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 20),
                for (var indicator in indicators) ...[
                  indicator,
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: actionButton,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleIndicator extends StatelessWidget {
  const SimpleIndicator({
    super.key,
    required this.label,
    required this.indicator,
  });

  final String label;
  final Widget indicator;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        indicator,
      ],
    );
  }
}

class ActionableIndicator extends StatelessWidget {
  const ActionableIndicator({
    super.key,
    required this.label,
    required this.indicator,
    required this.action,
  });

  final String label;
  final Widget indicator;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Row(
          children: [
            indicator,
            const SizedBox(width: 12),
            action,
          ],
        ),
      ],
    );
  }
}

enum StatusChipState { disabled, warning, ready }

final Map<StatusChipState, Color?> statusToColor = Map.of({
  StatusChipState.ready: Colors.greenAccent[200],
  StatusChipState.disabled: Colors.black12,
  StatusChipState.warning: Colors.redAccent[200],
});

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.state});

  final String label;
  final StatusChipState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 100,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: statusToColor[state],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class StatusChipLight extends StatelessWidget {
  const StatusChipLight({super.key, required this.state});

  final StatusChipState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: statusToColor[state],
        ),
      ),
    );
  }
}
