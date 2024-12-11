part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {}

final class AuthSignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  AuthSignUpEvent(
      {required this.name, required this.email, required this.password});

  @override
  List<Object> get props => [name, email, password];
}
