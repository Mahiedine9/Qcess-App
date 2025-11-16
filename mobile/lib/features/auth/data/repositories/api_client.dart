import 'package:dio/dio.dart';
import 'package:mobile/core/network/base_api_repository.dart';

class ApiClient extends BaseApiRepository {
  ApiClient(Dio dio) : super(dio);
}