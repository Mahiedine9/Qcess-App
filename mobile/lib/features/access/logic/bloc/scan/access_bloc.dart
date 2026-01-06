import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/access/data/dto/access_request_dto.dart';
import 'package:mobile/features/access/data/dto/access_response_dto.dart';
import 'package:mobile/features/access/data/repositories/i_access_repository.dart';
import 'package:mobile/features/access/logic/bloc/scan/access_event.dart';
import 'package:mobile/features/access/logic/bloc/scan/access_state.dart';

class AccessBloc extends Bloc<AccessEvent, AccessState> {
  final IAccessRepository _repository;

  AccessBloc({
    required IAccessRepository repository,
  })  : _repository = repository,
        super(AccessInitial()) {
    on<ScanQrCodeEvent>(_onScanQrCode);
    on<ResetAccessEvent>(_onResetAccess);
  }

  Future<void> _onScanQrCode(
    ScanQrCodeEvent event,
    Emitter<AccessState> emit,
  ) async {
    emit(AccessScanning());

    try {
      final request = AccessRequestDTO(
        zoneId: event.zoneId,
      );

      final response = await _repository.scanQrCode(request);

      emit(QrCodeScanned(event.zoneId));

      if (response.granted) {
        emit(AccessSuccess(response));
      } else {
        emit(AccessDenied(response));
      }
    } catch (e) {
      final raw = e.toString();
      final lower = raw.toLowerCase();
      if (lower.contains('accès refusé') || lower.contains('access denied') || lower.contains('forbidden')) {
        emit(AccessDenied(
          AccessResponseDTO(granted: false, reason: 'PERMISSION_DENIED', zoneName: ''),
        ));
      } else {
        emit(AccessError('Erreur lors du scan: ${e.toString()}'));
      }
    }
  }

  void _onResetAccess(
    ResetAccessEvent event,
    Emitter<AccessState> emit,
  ) {
    emit(AccessInitial());
  }
}

