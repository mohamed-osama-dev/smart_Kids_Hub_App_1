class DoctorSpecialty {
  final String key;
  final String label;
  final String emoji;

  const DoctorSpecialty({
    required this.key,
    required this.label,
    required this.emoji,
  });

  static const List<DoctorSpecialty> allSpecialties = [
    DoctorSpecialty(key: 'all', label: 'الكل', emoji: '🏥'),
    DoctorSpecialty(key: 'general', label: 'طب أطفال عام', emoji: '👶'),
    DoctorSpecialty(key: 'nutrition', label: 'تغذية', emoji: '🥗'),
    DoctorSpecialty(key: 'neurology', label: 'أعصاب أطفال', emoji: '🧠'),
    DoctorSpecialty(key: 'cardiology', label: 'قلب الأطفال', emoji: '❤️'),
    DoctorSpecialty(key: 'dermatology', label: 'جلدية أطفال', emoji: '🩺'),
    DoctorSpecialty(key: 'dental', label: 'أسنان أطفال', emoji: '🦷'),
  ];
}
