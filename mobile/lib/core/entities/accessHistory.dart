import 'package:equatable/equatable.dart';

class AccessHistory extends Equatable {
  final String id;
  final String zoneName;
  final String zoneId;
  final DateTime accessTime;
  final AccessStatus status;

  const AccessHistory({
    required this.id,
    required this.zoneName,
    required this.zoneId,
    required this.accessTime,
    required this.status,
  });

  @override
  List<Object?> get props => [id, zoneName, zoneId, accessTime, status];
}

enum AccessStatus {
  authorized,
  denied,
  pending,
}