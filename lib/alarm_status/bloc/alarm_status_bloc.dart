import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:alarmapp_pwa/repositories/alarm_system_repository.dart';
import 'package:alarmapp_pwa/models/alarm_state.dart';

part 'alarm_status_event.dart';
part 'alarm_status_state.dart';

class AlarmStatusBloc extends Bloc<AlarmStatusEvent, AlarmStatusState> {
  AlarmStatusBloc(this._alarmSystemRepository)
      : super(const UnmonitoredState()) {
    on<StartAlarmStateStreamRequested>(_onStartAlarmStateStreamRequested);
    on<StateChanged>(_onStateChanged);
    on<ToggleAreaRequested>(_onToggleAreaRequested);
    on<ActivateSystemRequested>(_onActivateSystemRequested);
    on<ActivateSystemForAreasRequested>(_onActivateSystemForAreasRequested);
    on<DeactivateSystemRequested>(_onDeactivateSystemRequested);
    on<PanicRequested>(_panicRequested);
    on<SirenTestRequested>(_testSiren);
  }

  final AlarmSystemRepository _alarmSystemRepository;

  Future<void> _onStartAlarmStateStreamRequested(
      StartAlarmStateStreamRequested event,
      Emitter<AlarmStatusState> emit) async {
    await _getSystemState(emit);

    _alarmSystemRepository
        .startAlarmStateStream((state) => add(StateChanged(state)));
  }

  void _onStateChanged(StateChanged event, Emitter<AlarmStatusState> emit) {
    emit(MonitoredState(event.state));
  }

  void _onToggleAreaRequested(
      ToggleAreaRequested event, Emitter<AlarmStatusState> emit) {
    final alarmState = (state as MonitoredState).state;
    final disabledAreas = {...alarmState.disabledAreas};

    if (alarmState.disabledAreas.contains(event.area)) {
      disabledAreas.remove(event.area);
    } else {
      disabledAreas.add(event.area);
    }

    emit(MonitoredState(alarmState.copyWith(disabledAreas: disabledAreas)));
  }

  Future<void> _onActivateSystemRequested(
      ActivateSystemRequested event, Emitter<AlarmStatusState> emit) async {
    final alarmState = (state as MonitoredState).state;

    await _alarmSystemRepository.activateSystem(
        alarmState.areas, alarmState.disabledAreas);
    await _getSystemState(emit);
  }

  Future<void> _onActivateSystemForAreasRequested(
      ActivateSystemForAreasRequested event,
      Emitter<AlarmStatusState> emit) async {
    final alarmState = (state as MonitoredState).state;
    final disabledAreas = {...alarmState.areas};

    disabledAreas.removeAll(event.areas);
    emit(MonitoredState(alarmState.copyWith(disabledAreas: disabledAreas)));
    await _getSystemState(emit);
  }

  Future<void> _onDeactivateSystemRequested(
      DeactivateSystemRequested event, Emitter<AlarmStatusState> emit) async {
    await _alarmSystemRepository.deactivateSystem();
    await _getSystemState(emit);
  }

  void _testSiren(SirenTestRequested event, Emitter<AlarmStatusState> emit) {
    _alarmSystemRepository.testSiren();
  }

  void _panicRequested(PanicRequested event, Emitter<AlarmStatusState> emit) {
    _alarmSystemRepository.postPanic();
  }

  Future<void> _getSystemState(Emitter<AlarmStatusState> emit) async {
    await _alarmSystemRepository
        .getSystemState()
        .then((state) => emit(MonitoredState(state)));
  }
}
