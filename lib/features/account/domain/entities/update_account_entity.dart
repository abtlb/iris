class UpdateAccountEntity {
  final String username;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? email;

  UpdateAccountEntity({required this.username, required this.firstName, required this.lastName, required this.dateOfBirth, required this.email});

  UpdateAccountEntity copyWith({
    String? firstName,
    String? lastName,
    String? email,
    DateTime? dob,}) {
    return UpdateAccountEntity(
      username: username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dob ?? dateOfBirth,
      email: email ?? this.email,);
  }
}