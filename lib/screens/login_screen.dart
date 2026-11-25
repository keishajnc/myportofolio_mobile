import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      await context.read<AuthState>().login(_username.trim(), _password);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Login dengan akun Django. Menambah proyek memerlukan akun superuser.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                autofillHints: const [AutofillHints.username],
                textInputAction: TextInputAction.next,
                onChanged: (value) => _username = value,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Username tidak boleh kosong!'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                enabled: !_isSubmitting,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                autofillHints: const [AutofillHints.password],
                onChanged: (value) => _password = value,
                onFieldSubmitted: (_) => _submit(),
                validator: (value) => value == null || value.isEmpty
                    ? 'Password tidak boleh kosong!'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
