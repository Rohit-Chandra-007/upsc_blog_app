import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsc_blog_app/core/usecase/usecase.dart';
import 'package:upsc_blog_app/features/auth/domain/entities/user.dart';
import 'package:upsc_blog_app/features/auth/domain/usecases/current_user.dart';
import 'package:upsc_blog_app/features/auth/domain/usecases/user_sign_in.dart';
import 'package:upsc_blog_app/features/auth/domain/usecases/user_sign_up.dart';
import 'package:upsc_blog_app/core/services/logger_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserSignIn _userSignIn;
  final CurrentUser _currentUser;
  AuthBloc(
      {required UserSignUp userSignup,
      required UserSignIn userSignIn,
      required CurrentUser currentUser})
      : _userSignUp = userSignup,
        _userSignIn = userSignIn,
        _currentUser = currentUser,
        super(AuthInitial()) {
    on<AuthSignUpEvent>(_authSignUpEvent);
    on<AuthSignInEvent>(_authSignInEvent);
    on<AuthIsUserSignedInEvent>(_isUserSignedIn);
  }

  void _authSignUpEvent(AuthSignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final response = await _userSignUp(
      UserSignUpParams(
          name: event.name, email: event.email, password: event.password),
    );

    response.fold((failure) {
      emit(AuthFailure(failure.message));
    }, (user) {
      emit(AuthSuccess(user));
    });
  }

  void _authSignInEvent(AuthSignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final response = await _userSignIn(
      UserSignInParams(email: event.email, password: event.password),
    );
    response.fold((failure) {
      emit(AuthFailure(failure.message));
    }, (user) {
      emit(AuthSuccess(user));
    });
  }

  void _isUserSignedIn(
      AuthIsUserSignedInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final response = await _currentUser(NoParams());
    response.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) {
        logger.info(user.name);
        logger.info(user.email);
        emit(AuthSuccess(user));
      },
    );
  }
}
