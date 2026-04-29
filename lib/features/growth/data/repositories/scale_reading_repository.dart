import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class ScaleReadingRepository {
  final _client = DioClient();

  Future<bool> updateWeight({
    required int childId,
    required double weight,
  }) async {
    final url = '${ApiConstants.updateWeight}/$childId';
    final data = {'weight': weight};
    print(' PUT $url → $data');

    try {
      final response = await _client.dio.put(url, data: data);
      print('Response: ${response.data}');
      return response.data?['success'] == true;
    } on DioException catch (e) {
      print('Status: ${e.response?.statusCode}');
      print('Response body: ${e.response?.data}');
      rethrow;
    }
  }
}
