import 'package:first_flutter_project/network/authentication/user_authentication.dart';
import 'package:first_flutter_project/pages/authentication/login/auth_bottom_sheet_state.dart';
import 'package:first_flutter_project/pages/authentication/login/login_form.dart';
import 'package:first_flutter_project/pages/authentication/login/sign_up.dart';
import 'package:flutter/material.dart';

class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key});

  static Future<bool> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => const AuthBottomSheet(),
    ).then((v) => v ?? false);
  }

  @override
  State<AuthBottomSheet> createState() => AuthBottomSheetState();
}

// LOGIN FORM
class LoginForm extends StatefulWidget {
  final VoidCallback onSuccess;
  const LoginForm({super.key, required this.onSuccess});

  @override
  State<LoginForm> createState() => LoginFormState();
}

// SIGNUP FORM

class SignupForm extends StatefulWidget {
  final VoidCallback onSuccess;

  const SignupForm({super.key, required this.onSuccess});

  @override
  State<SignupForm> createState() => SignupFormState();
}

