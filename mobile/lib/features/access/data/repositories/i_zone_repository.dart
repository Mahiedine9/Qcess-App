import 'package:mobile/features/access/data/dto/zone_dto.dart';

abstract class IZoneRepository {
  Future<List<ZoneDTO>> getAccessibleZones();
}
