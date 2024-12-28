part of 'app_user_cubit.dart';

/// core cannot depend on other features
/// feature can depend on core
@immutable
sealed class AppUserState extends Equatable {
  const AppUserState();

  @override
  List<Object> get props => [];
}

final class AppUserInitial extends AppUserState {}

final class AppUserSignedIn extends AppUserState {
  final User user;
  const AppUserSignedIn(this.user);

  @override
  List<Object> get props => [user];
}
