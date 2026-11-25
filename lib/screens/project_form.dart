import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _techStack = TextEditingController();
  final _projectUrl = TextEditingController();
  final _imageUrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (final controller in [
      _title,
      _description,
      _techStack,
      _projectUrl,
      _imageUrl,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'Isian ini tidak boleh kosong!'
      : null;

  String? _validateUrl(String? value, {bool optional = false}) {
    final text = value?.trim() ?? '';
    if (optional && text.isEmpty) return null;
    if (text.isEmpty) return 'URL proyek tidak boleh kosong!';
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        !['http', 'https'].contains(uri.scheme) ||
        text.contains(RegExp(r'\s'))) {
      return 'Masukkan URL lengkap dengan http:// atau https://.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      final loggedIn = await ensureLoggedIn(context);
      if (!mounted || !loggedIn) return;
      final auth = context.read<AuthState>();
      final token = auth.token;
      if (token == null) return;
      final saved = await context.read<ApiClient>().createProject(
        Project(
          title: _title.text.trim(),
          description: _description.text.trim(),
          techStack: _techStack.text.trim(),
          projectUrl: _projectUrl.text.trim(),
          projectImageUrl: _imageUrl.text.trim(),
        ),
        token: token,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${saved.title}'),
                Text('Description: ${saved.description}'),
                Text('Tech Stack: ${saved.techStack}'),
                Text('Project URL: ${saved.projectUrl}'),
                if (saved.projectImageUrl.isNotEmpty)
                  Text('Project Image URL: ${saved.projectImageUrl}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      for (final controller in [
        _title,
        _description,
        _techStack,
        _projectUrl,
        _imageUrl,
      ]) {
        controller.clear();
      }
      _formKey.currentState!.reset();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      if (error.statusCode == 401) {
        context.read<AuthState>().clearSession();
        await ensureLoggedIn(context);
        // Preserve the form; the user can retry Save after signing in again.
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
    bool url = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      enabled: !_isSubmitting,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: url ? TextInputType.url : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator ?? _required,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project Form'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field('Title', _title, maxLength: 255),
              _field('Description', _description, maxLines: 5),
              _field('Tech Stack', _techStack, maxLength: 255),
              _field(
                'Project URL',
                _projectUrl,
                validator: _validateUrl,
                maxLength: 200,
                url: true,
              ),
              _field(
                'Project Image URL (Optional)',
                _imageUrl,
                validator: (value) => _validateUrl(value, optional: true),
                maxLength: 200,
                url: true,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
