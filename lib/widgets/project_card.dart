import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (item.name == 'Logout') {
            await logoutWithFeedback(context);
            return;
          }
          if (item.name == 'Login') {
            await ensureLoggedIn(context);
            return;
          }
          if (item.name == 'Tambah Proyek') {
            final loggedIn = await ensureLoggedIn(context);
            if (!context.mounted || !loggedIn) return;
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProjectFormPage()),
            );
            return;
          }
          if (item.name == 'Lihat Proyek') {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProjectListScreen()),
            );
            return;
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Kamu telah menekan tombol ${item.name}!'),
              ),
            );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
