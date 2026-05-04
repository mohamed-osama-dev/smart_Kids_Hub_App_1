import '../entities/entities.dart';

abstract class DoctorRepository {
  Future<List<Doctor>> getDoctors({String? specialtyKey});
}
