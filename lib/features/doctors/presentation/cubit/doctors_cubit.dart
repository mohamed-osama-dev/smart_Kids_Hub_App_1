import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/get_doctors.dart';

enum DoctorsStatus { initial, loading, loaded, error }

class DoctorsState {
  final DoctorsStatus status;
  final List<Doctor> allDoctors;
  final List<Doctor> filteredDoctors;
  final String selectedSpecialtyKey;
  final String? errorMessage;

  const DoctorsState({
    this.status = DoctorsStatus.initial,
    this.allDoctors = const [],
    this.filteredDoctors = const [],
    this.selectedSpecialtyKey = 'all',
    this.errorMessage,
  });

  int get doctorCount => filteredDoctors.length;

  DoctorsState copyWith({
    DoctorsStatus? status,
    List<Doctor>? allDoctors,
    List<Doctor>? filteredDoctors,
    String? selectedSpecialtyKey,
    String? errorMessage,
  }) {
    return DoctorsState(
      status: status ?? this.status,
      allDoctors: allDoctors ?? this.allDoctors,
      filteredDoctors: filteredDoctors ?? this.filteredDoctors,
      selectedSpecialtyKey:
          selectedSpecialtyKey ?? this.selectedSpecialtyKey,
      errorMessage: errorMessage,
    );
  }
}

class DoctorsCubit extends ChangeNotifier {
  final GetDoctors _getDoctors;
  DoctorsState _state = const DoctorsState();

  DoctorsCubit({required GetDoctors getDoctors}) : _getDoctors = getDoctors;

  DoctorsState get state => _state;

  Future<void> loadDoctors() async {
    if (_state.status == DoctorsStatus.loaded &&
        _state.selectedSpecialtyKey == 'all') {
      return;
    }

    _state = _state.copyWith(
      status: DoctorsStatus.loading,
      errorMessage: null,
    );
    notifyListeners();

    try {
      final doctors = await _getDoctors(specialtyKey: null);
      _state = _state.copyWith(
        status: DoctorsStatus.loaded,
        allDoctors: doctors,
        filteredDoctors: doctors,
        selectedSpecialtyKey: 'all',
      );
    } catch (e) {
      _state = _state.copyWith(
        status: DoctorsStatus.error,
        errorMessage:
            e is ApiException ? e.message : 'تعذر تحميل قائمة الأطباء',
      );
    }
    notifyListeners();
  }

  void filterBySpecialty(String specialtyKey) {
    if (_state.status != DoctorsStatus.loaded) return;

    final filtered = specialtyKey == 'all'
        ? _state.allDoctors
        : _state.allDoctors
            .where((d) => d.specialtyKey == specialtyKey)
            .toList();

    _state = _state.copyWith(
      selectedSpecialtyKey: specialtyKey,
      filteredDoctors: filtered,
    );
    notifyListeners();
  }
}
