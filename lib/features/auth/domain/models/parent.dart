class Parent {
  final String? id;
  final String fullName;
  final String phone;
  final String password;

  Parent({
    this.id,
    required this.fullName,
    required this.phone,
    required this.password,
  });

  Parent copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? password,
  }) {
    return Parent(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      password: password ?? this.password,
    );
  }
}
