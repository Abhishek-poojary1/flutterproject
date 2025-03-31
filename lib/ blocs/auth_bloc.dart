import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutterproject/%20blocs/auth_bloc.dart' as firebaseAuthService;
import 'package:flutterproject/services/firebase_service.dart';
// import '../services/firebase_auth_service.dart';
import '../services/config_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// EVENTS
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  LoginWithEmailRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginWithGoogleRequested extends AuthEvent {}

class LoginWithAppleRequested extends AuthEvent {}

class PhoneVerificationRequested extends AuthEvent {
  final String phoneNumber;

  PhoneVerificationRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class PhoneVerificationCodeSubmitted extends AuthEvent {
  final String verificationId;
  final String smsCode;

  PhoneVerificationCodeSubmitted({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object?> get props => [verificationId, smsCode];
}

class SignOutRequested extends AuthEvent {}

class CheckAuthenticationStatus extends AuthEvent {}

// STATES
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user.uid];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class PhoneVerificationSent extends AuthState {
  final String verificationId;

  PhoneVerificationSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

// BLOC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService firebaseAuthService;
  final ConfigService configService;

  AuthBloc({
    required this.firebaseAuthService,
    required this.configService,
  }) : super(AuthInitial()) {
    on<LoginWithEmailRequested>(_onLoginWithEmailRequested);
    on<LoginWithGoogleRequested>(_onLoginWithGoogleRequested);
    on<LoginWithAppleRequested>(_onLoginWithAppleRequested);
    on<PhoneVerificationRequested>(_onPhoneVerificationRequested);
    on<PhoneVerificationCodeSubmitted>(_onPhoneVerificationCodeSubmitted);
    on<SignOutRequested>(_onSignOutRequested);
    on<CheckAuthenticationStatus>(_onCheckAuthenticationStatus);
    on<SignUpWithEmailRequested>(
        _onSignUpWithEmailRequested); // Add this line inside the constructor
  }

  Future<void> _onLoginWithEmailRequested(
    LoginWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await firebaseAuthService.signInWithEmail(
        event.email,
        event.password,
      );
      emit(AuthAuthenticated(credential.user!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginWithGoogleRequested(
      LoginWithGoogleRequested event, Emitter<AuthState> emit) async {
    if (!configService.isAuthMethodEnabled('google')) {
      emit(AuthError('Google authentication is not enabled'));
      return;
    }

    emit(AuthLoading());
    try {
      final userCredential = await firebaseAuthService.signInWithGoogle();
      emit(AuthAuthenticated(userCredential.user!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginWithAppleRequested(
      LoginWithAppleRequested event, Emitter<AuthState> emit) async {
    if (!configService.isAuthMethodEnabled('apple')) {
      emit(AuthError('Apple authentication is not enabled'));
      return;
    }

    emit(AuthLoading());
    try {
      final userCredential = await firebaseAuthService.signInWithApple();
      emit(AuthAuthenticated(userCredential.user!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPhoneVerificationRequested(
      PhoneVerificationRequested event, Emitter<AuthState> emit) async {
    if (!configService.isAuthMethodEnabled('phone')) {
      emit(AuthError('Phone authentication is not enabled'));
      return;
    }

    emit(AuthLoading());

    // Create a Completer to wait for the callbacks
    final completer = Completer<void>();

    try {
      await firebaseAuthService.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Check if we can still emit
          if (!emit.isDone) {
            try {
              final userCredential = await firebaseAuthService
                  .signInWithPhoneCredential(credential);
              emit(AuthAuthenticated(userCredential.user!));
            } catch (e) {
              emit(AuthError(e.toString()));
            }
          }
          if (!completer.isCompleted) completer.complete();
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!emit.isDone) {
            emit(AuthError(e.message ?? 'Phone verification failed'));
          }
          if (!completer.isCompleted) completer.complete();
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!emit.isDone) {
            emit(PhoneVerificationSent(verificationId));
          }
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
          if (!completer.isCompleted) completer.complete();
        },
      );

      // Wait for one of the callbacks to complete
      await completer.future;
    } catch (e) {
      if (!emit.isDone) {
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> _onPhoneVerificationCodeSubmitted(
      PhoneVerificationCodeSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      );

      final userCredential =
          await firebaseAuthService.signInWithPhoneCredential(credential);
      emit(AuthAuthenticated(userCredential.user!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
      SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await firebaseAuthService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthenticationStatus(
      CheckAuthenticationStatus event, Emitter<AuthState> emit) async {
    final user = firebaseAuthService.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}

// Add this to your AuthEvent classes
class SignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  SignUpWithEmailRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

// Add this to your FirebaseAuthService class
Future<UserCredential> createUserWithEmail(
  String email,
  String password,
  String name,
) async {
  final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  // Update the user profile with the name
  await userCredential.user?.updateDisplayName(name);

  return userCredential;
}

// Add this handler in your AuthBloc class
// on<SignUpWithEmailRequested>(_onSignUpWithEmailRequested);

// Implement the handler
Future<void> _onSignUpWithEmailRequested(
  SignUpWithEmailRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());
  try {
    final credential = await firebaseAuthService.createUserWithEmail(
      event.email,
      event.password,
      event.name,
    );
    emit(AuthAuthenticated(credential.user!));
  } catch (e) {
    emit(AuthError(e.toString()));
  }
}
