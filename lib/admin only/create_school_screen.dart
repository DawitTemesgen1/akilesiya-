import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amde_haymanot_abalat_guday/services/tenant_service.dart';

class CreateSchoolScreen extends StatefulWidget {
  const CreateSchoolScreen({super.key});

  @override
  State<CreateSchoolScreen> createState() => _CreateSchoolScreenState();
}

class _CreateSchoolScreenState extends State<CreateSchoolScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _primaryColorController = TextEditingController(text: '#012564');
  final _accentColorController = TextEditingController(text: '#FFD700');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _logoUrlController.dispose();
    _primaryColorController.dispose();
    _accentColorController.dispose();
    super.dispose();
  }

  Future<void> _createSchool() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await TenantService.createTenant(
      name: _nameController.text.trim(),
      logoUrl: _logoUrlController.text.trim(),
      primaryColor: _primaryColorController.text.trim(),
      accentColor: _accentColorController.text.trim(),
    );

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('School created successfully!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${result['message']}'),
              backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Register New School', style: GoogleFonts.poppins())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('School Information',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'School Name*'),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _logoUrlController,
                decoration:
                    const InputDecoration(labelText: 'Logo URL (Optional)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _primaryColorController,
                decoration: const InputDecoration(
                    labelText: 'Primary Color (Hex)*', hintText: '#012564'),
                validator: (v) => v!.isEmpty ? 'Color is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _accentColorController,
                decoration: const InputDecoration(
                    labelText: 'Accent Color (Hex)*', hintText: '#FFD700'),
                validator: (v) => v!.isEmpty ? 'Color is required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _createSchool,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create School'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
