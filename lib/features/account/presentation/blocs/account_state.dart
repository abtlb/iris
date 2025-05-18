import 'package:equatable/equatable.dart';

enum AccountStatus { initial, loading, success, failure }

class AccountState extends Equatable {
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? imageUrl;
  final DateTime? dob;
  final AccountStatus status;
  final String? error;

  const AccountState({
    required this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.imageUrl,
    this.dob,
    this.status = AccountStatus.initial,
    this.error,
  });

  const AccountState.initial(this.username, this.firstName, this.lastName, this.email, this.imageUrl, this.dob, this.error):
    status = AccountStatus.initial;


  AccountState copyWith({
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? imageUrl,
    DateTime? dob,
    AccountStatus? status,
    String? error,
  }) {
    return AccountState(
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      dob: dob ?? this.dob,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [username, firstName, lastName, email, imageUrl, dob, status, error];
}
