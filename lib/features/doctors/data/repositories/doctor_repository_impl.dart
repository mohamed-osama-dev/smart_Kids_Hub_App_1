import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../models/doctor_model.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DioClient _client = DioClient();
  final bool useMock;

  DoctorRepositoryImpl({this.useMock = true});

  @override
  Future<List<Doctor>> getDoctors({String? specialtyKey}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      final all = DoctorModel.mockList;
      if (specialtyKey == null || specialtyKey == 'all') return all;
      return all.where((d) => d.specialtyKey == specialtyKey).toList();
    }

    try {
      final queryParams = (specialtyKey != null && specialtyKey != 'all')
          ? {'specialty': specialtyKey}
          : null;
      final response = await _client.dio.get(
        ApiConstants.getDoctors,
        queryParameters: queryParams,
      );
      final raw = response.data;
      if (raw is! Map<String, dynamic> || raw['success'] != true) {
        final message = raw is Map<String, dynamic>
            ? raw['message']?.toString()
            : null;
        throw ApiException(message ?? 'تعذر تحميل الأطباء');
      }
      final list = raw['data'] as List<dynamic>? ?? [];
      return list
          .whereType<Map>()
          .map((e) => DoctorModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.first.toString();
      }
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    return 'تعذر تحميل الأطباء';
  }
}
