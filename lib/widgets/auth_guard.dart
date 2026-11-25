import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

Future<bool> ensureLoggedIn(BuildContext context) async {
  final auth = context.read<AuthState>();
  if (auth.isLoggedIn) return true;
  final loggedIn = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
  return loggedIn == true && auth.isLoggedIn;
}

Future<void> logoutWithFeedback(BuildContext context) async {
  String message = 'Berhasil logout.';
  try {
    await context.read<AuthState>().logout();
  } catch (error) {
    message =
        'Sesi lokal dihapus. Token server belum dapat dicabut. ${apiErrorMessage(error)}';
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
