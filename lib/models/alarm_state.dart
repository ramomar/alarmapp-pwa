import 'package:equatable/equatable.dart';

final class AlarmState extends Equatable {
  const AlarmState({
    required this.areas,
    required this.disabledAreas,
    required this.openAreas,
    required this.isArmed,
    required this.hasSirenActive,
  });

  final Set<int> areas;
  final Set<int> disabledAreas;
  final Set<int> openAreas;
  final bool isArmed;
  final bool hasSirenActive;

  AlarmState copyWith(
          {Set<int>? areas,
          Set<int>? disabledAreas,
          Set<int>? openAreas,
          bool? isArmed,
          bool? hasSirenActive}) =>
      AlarmState(
        areas: areas ?? this.areas,
        disabledAreas: disabledAreas ?? this.disabledAreas,
        openAreas: openAreas ?? this.openAreas,
        isArmed: isArmed ?? this.isArmed,
        hasSirenActive: hasSirenActive ?? this.isArmed,
      );

  @override
  List<Object> get props => [
        areas.join('-'),
        disabledAreas.join('-'),
        openAreas.join('-'),
        isArmed,
        hasSirenActive,
      ];
}

final class AreaState extends Equatable {
  const AreaState({
    required this.areaNumber,
    required this.isOpen,
    required this.isDisabled,
  });

  final int areaNumber;
  final bool isOpen;
  final bool isDisabled;

  @override
  List<Object> get props => [
        areaNumber,
        isOpen,
        isDisabled,
      ];
}
