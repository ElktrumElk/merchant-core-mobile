import 'package:first_flutter_project/components/settings/user.dart';
import 'package:first_flutter_project/module/storage/device_storage.dart';
import 'package:first_flutter_project/network/authentication/user_authentication.dart';
import 'package:http/http.dart' as http;
import 'package:first_flutter_project/pages/authentication/login/user_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LoginFormState extends State<LoginForm> {


final _formKey = GlobalKey<FormState>();
final _emailCtrl = TextEditingController();
final _passCtrl = TextEditingController();
bool _obscure = true;
bool isValidating = false;

@override
void dispose() {
  _emailCtrl.dispose();
  _passCtrl.dispose();

  super.dispose();
}
void _submit() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    isValidating = true;
  });

  try {
    http.Response userLogin = await UserService().login(_emailCtrl.text, _passCtrl.text);

    if (!mounted) return;

    if (userLogin.statusCode == 200 || userLogin.statusCode == 201) {
      setState(() {
        isValidating = false;
      });

      // setUser login to true
      DeviceStorage.setKey('isLogin');
      DeviceStorage.saveValue('true');

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onSuccess();
      });
    } else {
      setState(() {
        isValidating = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Login'),
            content: const Text('Error '),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  } catch (e) {
    if (!mounted) return;
    setState(() {
      isValidating = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Connection Error'),
          content: Text('Could not connect to server. Check your connection and try again. $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  return Form(
    key: _formKey,
    child: ListView(
      padding: const EdgeInsets.only(top: 16),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildField(
          theme,
          controller: _emailCtrl,
          icon: Icons.email_outlined,
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter your email';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 14),
        _buildField(
          theme,
          controller: _passCtrl,
          icon: Icons.lock_outline,
          hint: 'Password',
          obscure: _obscure,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter your password';
            if (v.length < 6) return 'At least 6 characters';
            return null;
          },
          suffix: IconButton(
            icon: Icon(
              _obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Forgot Password?',
              style: TextStyle(color: Color(0xFF1565C0), fontSize: 13),
            ),
          ),
        ),

        // signIn button -----------------------------------------------------------------
        const SizedBox(height: 4),

        _buildButton(theme, label: isValidating ? 'Validating...' : 'Sign In', onTap: _submit),

      ],
    ),
  );
}

Widget _buildField(
    ThemeData theme, {
      required TextEditingController controller,
      required IconData icon,
      required String hint,
      required String? Function(String?) validator,
      TextInputType? keyboardType,
      bool obscure = false,
      Widget? suffix,
    }) {
  return TextFormField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboardType,
    style: TextStyle(color: theme.colorScheme.onSurface),
    decoration: _inputDecoration(
      theme,
      icon: icon,
      hint: hint,
      suffix: suffix,
    ),
    validator: validator,
  );
}

InputDecoration _inputDecoration(
    ThemeData theme, {
      required IconData icon,
      required String hint,
      Widget? suffix,
    }) {
  return InputDecoration(
    prefixIcon: Icon(icon, color: Colors.grey),
    suffixIcon: suffix,
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400),
    filled: true,
    fillColor: theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade100,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
  );
}

// submit button
Widget _buildButton(
    ThemeData theme, {
      required String label,
      required VoidCallback onTap,
    }) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient:  LinearGradient(
          colors: isValidating ? [Colors.grey, Colors.blueGrey] :[Color(0xFF0A0A0A), Color(0xFF161618)], // Login and signUp btn
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isValidating ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}
}