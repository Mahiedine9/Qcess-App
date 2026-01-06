abstract class AccessEvent {}

class ScanQrCodeEvent extends AccessEvent {
  final int zoneId;

  ScanQrCodeEvent(this.zoneId);
}
class ResetAccessEvent extends AccessEvent {}
