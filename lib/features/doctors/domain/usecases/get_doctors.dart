import '../entities/entities.dart';
import '../repositories/doctor_repository.dart';

class GetDoctors {
  final DoctorRepository repository;

  GetDoctors(this.repository);

  Future<List<Doctor>> call({String? specialtyKey}) =>
      repository.getDoctors(specialtyKey: specialtyKey);
}
