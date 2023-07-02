import 'package:alarmapp_pwa/alarm_status/bloc/alarm_status_bloc.dart';
import 'package:alarmapp_pwa/models/alarm_mappings.dart' as alarm_mappings;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/alarm_state.dart';

class AlarmStatusPage extends StatelessWidget {
  const AlarmStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmStatusBloc, AlarmStatusState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(left: 28, right: 28, top: 32),
          child: Stack(
            children: [
              ...switch (state) {
                MonitoredState(state: final s) => [
                    Center(
                      child: SingleChildScrollView(
                        child: StatusView(
                          alarmState: s,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: IconButton.filled(
                          iconSize: 36,
                          icon: s.isArmed
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                          onPressed: () => s.isArmed
                              ? context
                                  .read<AlarmStatusBloc>()
                                  .add(DeactivateSystemRequested())
                              : context
                                  .read<AlarmStatusBloc>()
                                  .add(ActivateSystemRequested()),
                        ),
                      ),
                    ),
                  ],
                UnmonitoredState() => [const SizedBox.shrink()],
              },
            ],
          ),
        );
      },
    );
  }
}

class StatusView extends StatelessWidget {
  const StatusView({super.key, required this.alarmState});

  final AlarmState alarmState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SummaryCard(
          title: 'General',
          height: 200,
          indicators: [
            SimpleIndicator(
              label: 'Sistema',
              indicator: StatusChip(
                label: alarmState.isArmed ? 'Armado' : 'Desarmado',
                state: alarmState.isArmed
                    ? StatusChipState.ready
                    : StatusChipState.disabled,
              ),
            ),
            SimpleIndicator(
              label: 'Sirena',
              indicator: StatusChip(
                label: alarmState.hasSirenActive ? 'Encendida' : 'Apagada',
                state: alarmState.hasSirenActive
                    ? StatusChipState.warning
                    : StatusChipState.disabled,
              ),
            ),
          ],
          actionButton: OutlinedButton.icon(
            onPressed: () =>
                BlocProvider.of<AlarmStatusBloc>(context).add(PanicRequested()),
            icon: const Icon(Icons.report),
            label: const Text('Emergencia'),
          ),
        ),
        const SizedBox(height: 18),
        SummaryCard(
          title: 'Primer piso',
          height: 360,
          indicators: [
            ...getFloorAreas(alarmState, 1)
                .map((area) => _buildArea(context, area)),
          ],
          actionButton: TextButton.icon(
            onPressed: alarmState.isArmed
                ? null
                : () => context.read<AlarmStatusBloc>().add(
                    ActivateSystemForAreasRequested(
                        getFloorAreas(alarmState, 1).toSet())),
            icon: const Icon(Icons.visibility),
            label: const Text('Vigilar solo aquí'),
          ),
        ),
        const SizedBox(height: 12),
        SummaryCard(
          title: 'Segundo piso',
          height: 248,
          indicators: [
            ...getFloorAreas(alarmState, 2)
                .map((area) => _buildArea(context, area)),
          ],
          actionButton: TextButton.icon(
            onPressed: alarmState.isArmed
                ? null
                : () => context.read<AlarmStatusBloc>().add(
                    ActivateSystemForAreasRequested(
                        getFloorAreas(alarmState, 2).toSet())),
            icon: const Icon(Icons.visibility),
            label: const Text('Vigilar solo aquí'),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  List<int> getFloorAreas(AlarmState state, int floor) {
    return state.areas
        .where((area) => alarm_mappings.areaToFloor[area] == floor)
        .toList();
  }

  Widget _buildArea(BuildContext context, int area) {
    final isDisabled = alarmState.disabledAreas.contains(area);
    final enabledAreaState = alarmState.openAreas.contains(area)
        ? StatusChipState.warning
        : StatusChipState.ready;

    return ActionableIndicator(
      label: alarm_mappings.areaToName[area] ?? '',
      indicator: StatusChipLight(
        state: isDisabled ? StatusChipState.disabled : enabledAreaState,
      ),
      action: IconButton(
        icon: Icon(alarmState.disabledAreas.contains(area)
            ? Icons.visibility
            : Icons.visibility_off),
        onPressed: alarmState.isArmed
            ? null
            : () =>
                context.read<AlarmStatusBloc>().add(ToggleAreaRequested(area)),
      ),
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
        SizedBox(
          width: 200,
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
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
