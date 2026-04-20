enum Gender { male, female }

class Child {
  final String? id;
  final String name;
  final DateTime birthDate;
  final Gender gender;
  final double? height;
  final double? weight;
  final List<String> healthConditions;
  final String additionalNotes;
  final bool hasNoChronicDiseases;

  Child({
    this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.height,
    this.weight,
    this.healthConditions = const [],
    this.additionalNotes = '',
    this.hasNoChronicDiseases = false,
  });

  int get ageInYears {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }

  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) {
      months--;
    }
    return months % 12;
  }

  String get ageString {
    if (ageInYears > 0) {
      if (ageInMonths > 0) {
        return '$ageInYears سنوات و $ageInMonths شهر';
      }
      return '$ageInYears سنوات';
    }
    return '$ageInMonths شهر';
  }

  Child copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    Gender? gender,
    double? height,
    double? weight,
    List<String>? healthConditions,
    String? additionalNotes,
    bool? hasNoChronicDiseases,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      healthConditions: healthConditions ?? this.healthConditions,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      hasNoChronicDiseases: hasNoChronicDiseases ?? this.hasNoChronicDiseases,
    );
  }
}
