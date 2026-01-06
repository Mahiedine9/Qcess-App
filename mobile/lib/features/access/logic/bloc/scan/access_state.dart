import 'package:mobile/features/access/data/dto/access_response_dto.dart';

abstract class AccessState {}

class AccessInitial extends AccessState {}

class AccessScanning extends AccessState {}

class AccessSuccess extends AccessState {
  final AccessResponseDTO response;

  AccessSuccess(this.response);
}

class AccessDenied extends AccessState {
  final AccessResponseDTO response;

  AccessDenied(this.response);
}

class AccessError extends AccessState {
  final String message;

  AccessError(this.message);
}

class ZoneQrCodeLoading extends AccessState {}

class ZoneQrCodeLoaded extends AccessState {
  final List<int> imageBytes;
  final int zoneId;

  ZoneQrCodeLoaded(this.imageBytes, this.zoneId);
}

class QrCodeScanned extends AccessState {
  final int zoneId;

  QrCodeScanned(this.zoneId);
}

class ZoneQrCodeError extends AccessState {
  final String message;

  ZoneQrCodeError(this.message);
}
