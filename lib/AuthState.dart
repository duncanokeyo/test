import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/routes.dart';

class AuthState<T extends StatefulWidget> extends SupabaseAuthState<T> {
  @override
  void onUnauthenticated() {
    if (mounted) {
      
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.login, (route) => false);
    }
  }

  @override
  void onAuthenticated(Session session) {
    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.home, (route) => false);
    }
  }

   @override
  void onPasswordRecovery(Session session) {
    Navigator.pushNamedAndRemoveUntil(
        context, Routes.forgotPassword, (route) => false);
  }

  @override
  void onErrorAuthenticating(String message) {
    print("on error authenticating $message");
  }
}
