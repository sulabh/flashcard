import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Locale Provider
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('en');
});

// Theme Mode Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// Mock Auth State
class AuthState {
  final bool isAuthenticated;
  final String? error;

  AuthState({this.isAuthenticated = false, this.error});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void login(String username, String password) {
    if (username == 'user' && password == 'password') {
      state = AuthState(isAuthenticated: true);
    } else {
      state = AuthState(isAuthenticated: false, error: 'Invalid credentials');
    }
  }

  void logout() {
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
