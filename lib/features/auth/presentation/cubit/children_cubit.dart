import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/services/hive_service.dart';
import '../../data/repositories/children_repository.dart';
import '../../domain/models/child_profile.dart';

enum ChildrenStatus { initial, loading, loaded, error }

class ChildrenState {
  final ChildrenStatus status;
  final List<ChildProfile> children;
  final int activeChildIndex;
  final String? errorMessage;

  const ChildrenState({
    this.status = ChildrenStatus.initial,
    this.children = const [],
    this.activeChildIndex = 0,
    this.errorMessage,
  });

  ChildProfile? get activeChild {
    if (children.isEmpty) return null;
    if (activeChildIndex < 0 || activeChildIndex >= children.length) {
      return children.first;
    }
    return children[activeChildIndex];
  }

  ChildrenState copyWith({
    ChildrenStatus? status,
    List<ChildProfile>? children,
    int? activeChildIndex,
    String? errorMessage,
  }) {
    return ChildrenState(
      status: status ?? this.status,
      children: children ?? this.children,
      activeChildIndex: activeChildIndex ?? this.activeChildIndex,
      errorMessage: errorMessage,
    );
  }
}

class ChildrenCubit extends ChangeNotifier {
  final ChildrenRepository _repository;
  ChildrenState _state = const ChildrenState();

  ChildrenCubit({ChildrenRepository? repository})
      : _repository = repository ?? ChildrenRepository();

  ChildrenState get state => _state;

  Future<void> loadChildren() async {
    _state = _state.copyWith(
      status: ChildrenStatus.loading,
      errorMessage: null,
    );
    notifyListeners();

    try {
      final children = await _repository.getChildren();
      _state = _state.copyWith(
        status: ChildrenStatus.loaded,
        children: children,
        activeChildIndex: _normalizeActiveIndex(
          _state.activeChildIndex,
          children.length,
        ),
        errorMessage: null,
      );
      notifyListeners();
      return;
    } catch (e) {
      final cachedChildren = HiveService.getCachedChildren();
      if (cachedChildren.isNotEmpty) {
        _state = _state.copyWith(
          status: ChildrenStatus.loaded,
          children: cachedChildren,
          activeChildIndex: _normalizeActiveIndex(
            _state.activeChildIndex,
            cachedChildren.length,
          ),
          errorMessage: null,
        );
        notifyListeners();
        return;
      }

      _state = _state.copyWith(
        status: ChildrenStatus.error,
        children: const [],
        activeChildIndex: 0,
        errorMessage: e is ApiException ? e.message : 'تعذر تحميل بيانات الأطفال',
      );
      notifyListeners();
    }
  }

  void setActiveChild(int index) {
    if (index < 0 || index >= _state.children.length) return;
    if (index == _state.activeChildIndex) return;

    _state = _state.copyWith(activeChildIndex: index, errorMessage: null);
    notifyListeners();
  }

  Future<void> addChildAndRefresh() async {
    _state = _state.copyWith(
      status: ChildrenStatus.loading,
      errorMessage: null,
    );
    notifyListeners();

    try {
      final children = await _repository.getChildrenFresh();
      _state = _state.copyWith(
        status: ChildrenStatus.loaded,
        children: children,
        activeChildIndex: _normalizeActiveIndex(
          _state.activeChildIndex,
          children.length,
        ),
        errorMessage: null,
      );
    } catch (_) {
      // Fresh fetch failed — try Hive cache as last resort.
      final cached = HiveService.getCachedChildren();
      _state = _state.copyWith(
        status: cached.isNotEmpty
            ? ChildrenStatus.loaded
            : ChildrenStatus.error,
        children: cached,
        errorMessage: cached.isEmpty ? 'تعذر تحميل بيانات الأطفال' : null,
      );
    }
    notifyListeners();
  }

  int _normalizeActiveIndex(int currentIndex, int length) {
    if (length <= 0) return 0;
    if (currentIndex < 0 || currentIndex >= length) return 0;
    return currentIndex;
  }
}

