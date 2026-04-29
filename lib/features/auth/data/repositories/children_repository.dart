import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/hive_service.dart';
import '../../domain/models/child_profile.dart';

class ChildrenRepository {
  final DioClient _client;

  ChildrenRepository({DioClient? client}) : _client = client ?? DioClient();

  Future<List<ChildProfile>> getChildren() async {
    final cachedChildren = HiveService.getCachedChildren();
    if (cachedChildren.isNotEmpty) {
      unawaited(_refreshChildrenCacheSilently());
      return cachedChildren;
    }

    try {
      return await _fetchChildrenAndCache();
    } on DioException catch (e) {
      throw ApiException(_extractDioMessage(e));
    } on ApiException catch (e) {
      throw ApiException(e.message.isNotEmpty ? e.message : 'تعذر تحميل بيانات الأطفال');
    } catch (_) {
      throw ApiException('تعذر تحميل بيانات الأطفال');
    }
  }

  Future<List<ChildProfile>> getChildrenFresh() async {
    try {
      return await _fetchChildrenAndCache();
    } on DioException catch (e) {
      throw ApiException(_extractDioMessage(e));
    } catch (_) {
      throw ApiException('تعذر تحميل بيانات الأطفال');
    }
  }

  Future<void> _refreshChildrenCacheSilently() async {
    try {
      await _fetchChildrenAndCache();
    } catch (_) {
      // Cache refresh failures are intentionally ignored in background mode.
    }
  }

  Future<List<ChildProfile>> _fetchChildrenAndCache() async {
    final response = await _client.dio.get(ApiConstants.getChildren);
    final raw = response.data;

    if (raw is! Map<String, dynamic>) {
      throw ApiException('تعذر تحميل بيانات الأطفال');
    }

    if (raw['success'] != true) {
      throw ApiException(raw['message']?.toString() ?? 'تعذر تحميل بيانات الأطفال');
    }

    final listData = raw['data'];
    if (listData is! List) {
      throw ApiException('تعذر تحميل بيانات الأطفال');
    }

    final children = listData
        .whereType<Map>()
        .map((e) => ChildProfile.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    await HiveService.saveChildren(children);
    return children;
  }

  String _extractDioMessage(DioException e) {
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
    return 'تعذر تحميل بيانات الأطفال';
  }
}

