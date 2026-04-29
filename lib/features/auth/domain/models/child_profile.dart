import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class ChildProfile {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String gender;
  @HiveField(3)
  final DateTime birthDate;
  @HiveField(4)
  final int age;
  @HiveField(5)
  final double length;
  @HiveField(6)
  final double weight;
  @HiveField(7)
  final double bmi;

  const ChildProfile({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.age,
    required this.length,
    required this.weight,
    required this.bmi,
  });

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    final rawBirthDate = json['birthDate']?.toString() ?? '';
    final parsedBirthDate = DateTime.tryParse(rawBirthDate) ?? DateTime(2000, 1, 1);

    return ChildProfile(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'Male',
      birthDate: parsedBirthDate,
      age: _asInt(json['age']),
      length: _asDouble(json['length']),
      weight: _asDouble(json['weight']),
      bmi: _asDouble(json['bmi']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'birthDate': birthDate.toIso8601String().split('T').first,
      'age': age,
      'length': length,
      'weight': weight,
      'bmi': bmi,
    };
  }

  String get ageLabel {
    // API currently returns age as an integer; if it is a total-months value,
    // this formats it as years + months, otherwise it falls back to years.
    if (age <= 0) return '';
    if (age <= 18) return '$age سنوات';

    final years = age ~/ 12;
    final months = age % 12;
    if (years > 0 && months > 0) {
      return '$years سنوات و $months أشهر';
    }
    if (years > 0) {
      return '$years سنوات';
    }
    return '$months أشهر';
  }

  String get genderEmoji => gender == 'Male' ? '👦' : '👧';

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
}

class ChildProfileAdapter extends TypeAdapter<ChildProfile> {
  @override
  final int typeId = 1;

  @override
  ChildProfile read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < fieldCount; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return ChildProfile(
      id: fields[0] as int? ?? 0,
      name: fields[1] as String? ?? '',
      gender: fields[2] as String? ?? 'Male',
      birthDate: fields[3] as DateTime? ?? DateTime(2000, 1, 1),
      age: fields[4] as int? ?? 0,
      length: (fields[5] as num?)?.toDouble() ?? 0.0,
      weight: (fields[6] as num?)?.toDouble() ?? 0.0,
      bmi: (fields[7] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  void write(BinaryWriter writer, ChildProfile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.birthDate)
      ..writeByte(4)
      ..write(obj.age)
      ..writeByte(5)
      ..write(obj.length)
      ..writeByte(6)
      ..write(obj.weight)
      ..writeByte(7)
      ..write(obj.bmi);
  }
}

