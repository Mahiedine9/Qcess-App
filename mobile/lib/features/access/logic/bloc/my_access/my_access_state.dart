import 'package:equatable/equatable.dart';
import 'package:mobile/features/access/data/dto/access_log_dto.dart';
import 'package:mobile/features/access/data/dto/zone_dto.dart';

enum LoadStatus { initial, loading, loaded, failure }

class MyAccessState extends Equatable {
  final LoadStatus zonesStatus;
  final LoadStatus logsStatus;
  final List<ZoneDTO> zones;
  final List<AccessLogDTO> logs;
  final String? zonesError;
  final String? logsError;

  const MyAccessState({
    this.zonesStatus = LoadStatus.initial,
    this.logsStatus = LoadStatus.initial,
    this.zones = const [],
    this.logs = const [],
    this.zonesError,
    this.logsError,
  });

  MyAccessState copyWith({
    LoadStatus? zonesStatus,
    LoadStatus? logsStatus,
    List<ZoneDTO>? zones,
    List<AccessLogDTO>? logs,
    String? zonesError,
    String? logsError,
  }) {
    return MyAccessState(
      zonesStatus: zonesStatus ?? this.zonesStatus,
      logsStatus: logsStatus ?? this.logsStatus,
      zones: zones ?? this.zones,
      logs: logs ?? this.logs,
      zonesError: zonesError,
      logsError: logsError,
    );
  }

  @override
  List<Object?> get props => [
        zonesStatus,
        logsStatus,
        zones,
        logs,
        zonesError,
        logsError,
      ];
}
