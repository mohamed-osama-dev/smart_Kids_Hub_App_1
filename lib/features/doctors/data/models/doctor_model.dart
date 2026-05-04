import '../../domain/entities/entities.dart';

class DoctorModel extends Doctor {
  const DoctorModel({
    required super.id,
    required super.name,
    required super.specialty,
    required super.specialtyKey,
    required super.rating,
    required super.reviewsCount,
    required super.experienceYears,
    required super.address,
    required super.phone,
    super.avatarUrl,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      specialty: json['specialty']?.toString() ?? '',
      specialtyKey: json['specialtyKey']?.toString() ?? 'general',
      rating: _asDouble(json['rating']),
      reviewsCount: _asInt(json['reviewsCount']),
      experienceYears: _asInt(json['experienceYears']),
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static List<DoctorModel> get mockList => const [
    DoctorModel(
      id: 1,
      name: 'د. أحمد محمود',
      specialty: 'استشاري طب أطفال عام',
      specialtyKey: 'general',
      rating: 4.9,
      reviewsCount: 234,
      experienceYears: 15,
      address: 'شارع الحجان المهندسين، الجيزة',
      phone: '+201001234567',
    ),
    DoctorModel(
      id: 2,
      name: 'د. سارة عبد الله',
      specialty: 'أخصائية تغذية الأطفال',
      specialtyKey: 'nutrition',
      rating: 4.8,
      reviewsCount: 189,
      experienceYears: 10,
      address: 'شارع التحرير، القاهرة',
      phone: '+201009876543',
    ),
    DoctorModel(
      id: 3,
      name: 'د. خالد إبراهيم',
      specialty: 'استشاري مع وأعصاب أطفال',
      specialtyKey: 'neurology',
      rating: 4.9,
      reviewsCount: 312,
      experienceYears: 20,
      address: 'شارع النيل، الجيزة',
      phone: '+201112223344',
    ),
    DoctorModel(
      id: 4,
      name: 'د. منى حسن',
      specialty: 'استشارية طب الأطفال',
      specialtyKey: 'general',
      rating: 4.7,
      reviewsCount: 156,
      experienceYears: 12,
      address: 'مدينة نصر، القاهرة',
      phone: '+201223344556',
    ),
    DoctorModel(
      id: 5,
      name: 'د. عمر السيد',
      specialty: 'أخصائي جلدية أطفال',
      specialtyKey: 'dermatology',
      rating: 4.6,
      reviewsCount: 98,
      experienceYears: 8,
      address: 'المعادي، القاهرة',
      phone: '+201334455667',
    ),
    DoctorModel(
      id: 6,
      name: 'د. ليلى فاروق',
      specialty: 'أخصائية أسنان أطفال',
      specialtyKey: 'dental',
      rating: 4.9,
      reviewsCount: 421,
      experienceYears: 14,
      address: 'الزمالك، القاهرة',
      phone: '+201445566778',
    ),
  ];
}
