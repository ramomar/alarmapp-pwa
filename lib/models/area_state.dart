import 'package:equatable/equatable.dart';

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
