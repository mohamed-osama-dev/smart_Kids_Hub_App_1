class Doctor {
  final int id;
  final String name;
  final String specialty;
  final String specialtyKey;
  final double rating;
  final int reviewsCount;
  final int experienceYears;
  final String address;
  final String phone;
  final String? avatarUrl;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.specialtyKey,
    required this.rating,
    required this.reviewsCount,
    required this.experienceYears,
    required this.address,
    required this.phone,
    this.avatarUrl,
  });
}
