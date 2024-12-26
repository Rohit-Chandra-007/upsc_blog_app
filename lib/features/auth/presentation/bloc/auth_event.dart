part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

final class AuthSignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

 const AuthSignUpEvent(
      {required this.name, required this.email, required this.password});

  @override
  List<Object> get props => [name, email, password];
}

final class AuthSignInEvent extends AuthEvent {
  final String email;
  final String password;

 const  AuthSignInEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

final class AuthIsUserSignedInEvent extends AuthEvent {
  const AuthIsUserSignedInEvent();
  @override
  List<Object> get props => [];
}
