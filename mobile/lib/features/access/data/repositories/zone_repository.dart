import 'package:mobile/core/network/base_api_repository.dart';
import 'package:mobile/features/access/data/dto/zone_dto.dart';
import 'package:mobile/features/access/data/repositories/i_zone_repository.dart';

class ZoneRepository extends BaseApiRepository implements IZoneRepository {
  ZoneRepository(super.dio);

  static const String _basePath = '/api/zones';

  @override
  Future<List<ZoneDTO>> getAccessibleZones() {
    return get<List<ZoneDTO>>(
      '$_basePath/me/accessible',
      fromJson: (data) {
        final list = data as List;
        return list
            .map((e) => ZoneDTO.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
