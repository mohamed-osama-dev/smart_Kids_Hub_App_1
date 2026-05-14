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
    super.avatarPath,
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
      avatarPath: json['avatarPath']?.toString(),
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
      name: 'Dr. Essam Hassan Samour (عصام حسن سمور)',
      specialty: 'إستشاري تخصص أطفال وحديثي الولادة',
      specialtyKey: 'general',
      rating: 5.0,
      reviewsCount: 227,
      experienceYears: 25,
      address: 'مصر الجديدة، ٤٣ ش الحجاز، المدخل الخلفي بجوار ميدان',
      phone: '+201044437797',
      avatarPath: 'assets/doctor1.png',
    ),
    DoctorModel(
      id: 2,
      name: 'Dr. Mostafa Wahdan (مصطفى وهدان)',
      specialty: 'إستشاري تخصص أطفال وحديثي الولادة',
      specialtyKey: 'general',
      rating: 5.0,
      reviewsCount: 138,
      experienceYears: 20,
      address: 'مركز طفلي فرع مدينة نصر، زهراء مدينة نصر، أبراج الصفا',
      phone: '+201044437797',
      avatarPath: 'assets/doctor2.png',
    ),
    DoctorModel(
      id: 3,
      name: 'Dr. Ziad Al-Khawahry (زياد الخواهري)',
      specialty: 'إستشاري تخصص أطفال وحديثي الولادة',
      specialtyKey: 'general',
      rating: 5.0,
      reviewsCount: 126,
      experienceYears: 22,
      address:
          'عيادة الدكتور زياد الخواهري، مدينة نصر، ٥ ش محمود إبراهيم، الدور الثاني',
      phone: '+201044437797',
      avatarPath: 'assets/doctor3.png',
    ),
    DoctorModel(
      id: 4,
      name: 'Dr. Ayman Abdel-Hay Ayoub (أيمن عبد الحي أيوب)',
      specialty: 'إستشاري تخصص أطفال وحديثي الولادة',
      specialtyKey: 'general',
      rating: 5.0,
      reviewsCount: 133,
      experienceYears: 18,
      address: 'مركز طفلي التجمع الخامس، القاهرة الجديدة، التجمع الخامس',
      phone: '+201044437797',
      avatarPath: 'assets/doctor4.png',
    ),
    DoctorModel(
      id: 5,
      name: 'Dr. Ahmed Ameen (أحمد أمين)',
      specialty: 'إستشاري تخصص أطفال وحديثي الولادة',
      specialtyKey: 'general',
      rating: 5.0,
      reviewsCount: 91,
      experienceYears: 16,
      address: 'مركز طفلي فرع مديتي، المركز الطبي الأول',
      phone: '+201044437797',
      avatarPath: 'assets/doctor5.png',
    ),
    DoctorModel(
      id: 6,
      name: 'Dr. Basem Hesham El-Sayed (باسم هشام السيد)',
      specialty: 'أخصائي تخصص أطفال وحديثي الولادة',
      specialtyKey: 'general',
      rating: 5.0,
      reviewsCount: 9,
      experienceYears: 12,
      address: 'عيادات السما التخصصية، مصر الجديدة، ٢٧ ش ميدان صلاح الدين',
      phone: '+201044437797',
      avatarPath: 'assets/doctor6.png',
    ),
  ];
}
