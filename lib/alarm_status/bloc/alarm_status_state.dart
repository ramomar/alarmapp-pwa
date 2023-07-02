part of 'alarm_status_bloc.dart';

sealed class AlarmStatusState extends Equatable {
  const AlarmStatusState();

  @override
  List<Object> get props => [];
}

final class UnmonitoredState extends AlarmStatusState {
  const UnmonitoredState();
}

final class MonitoredState extends AlarmStatusState {
  const MonitoredState(this.state);

  final AlarmState state;

  @override
  List<Object> get props => [
        state,
      ];
}
