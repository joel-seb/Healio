import 'package:flutter/material.dart';
import 'dashboard.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String _bloodType = 'O+';
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  final _auth = AuthService();

  static const _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _passwordCtrl, _ageCtrl, _heightCtrl, _weightCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final userData = await _auth.register(
        name: _nameCtrl.text.trim(),
        age: int.parse(_ageCtrl.text.trim()),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        bloodType: _bloodType,
        height: _heightCtrl.text.isNotEmpty ? double.tryParse(_heightCtrl.text) : null,
        weight: _weightCtrl.text.isNotEmpty ? double.tryParse(_weightCtrl.text) : null,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(userData: userData)),
        (_) => false,
      );
    } on ApiException catch (e) {
      setState(() { _errorMessage = e.message; });
    } catch (e) {
      setState(() { _errorMessage = 'Could not reach the server. Check your connection.'; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF20B2AA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              _field(_nameCtrl, 'Full Name', Icons.person_outline, validator: (v) =>
                  (v == null || v.isEmpty) ? 'Please enter your name' : null),
              const SizedBox(height: 16),

              _field(_emailCtrl, 'Email', Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your email';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  }),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordCtrl,
                obscureText: !_isPasswordVisible,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter a password';
                  if (v.length < 6) return 'Minimum 6 characters';
                  return null;
                },
                decoration: _dec(context, 'Password', Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Theme.of(context).iconTheme.color),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    )),
              ),
              const SizedBox(height: 16),

              _field(_ageCtrl, 'Age', Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your age';
                    final n = int.tryParse(v);
                    if (n == null || n < 1 || n > 120) return 'Enter a valid age';
                    return null;
                  }),
              const SizedBox(height: 16),

              // Blood type dropdown
              DropdownButtonFormField<String>(
                value: _bloodType,
                decoration: _dec(context, 'Blood Type', Icons.bloodtype_outlined),
                items: _bloodTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _bloodType = v!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _field(_heightCtrl, 'Height (cm)', Icons.height,
                      keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_weightCtrl, 'Weight (kg)', Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF20B2AA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Create Account',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      validator: validator,
      decoration: _dec(context, label, icon),
    );
  }

  InputDecoration _dec(BuildContext context, String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
      prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color),
      suffixIcon: suffix,
      filled: true,
      fillColor: Theme.of(context).cardTheme.color ?? Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
    );
  }
}
