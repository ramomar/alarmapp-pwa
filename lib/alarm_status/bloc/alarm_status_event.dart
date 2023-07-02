part of 'alarm_status_bloc.dart';

sealed class AlarmStatusEvent extends Equatable {
  const AlarmStatusEvent();

  @override
  List<Object> get props => [];
}

final class StartAlarmStateStreamRequested extends AlarmStatusEvent {}

final class SirenTestRequested extends AlarmStatusEvent {}

final class PanicRequested extends AlarmStatusEvent {}

final class ToggleAreaRequested extends AlarmStatusEvent {
  const ToggleAreaRequested(this.area);

  final int area;
}

final class ActivateSystemRequested extends AlarmStatusEvent {}

final class ActivateSystemForAreasRequested extends AlarmStatusEvent {
  const ActivateSystemForAreasRequested(this.areas);

  final Set<int> areas;
}

final class DeactivateSystemRequested extends AlarmStatusEvent {}

final class StateChanged extends AlarmStatusEvent {
  const StateChanged(this.state);

  final AlarmState state;

  @override
  List<Object> get props => [
        state,
      ];
}
