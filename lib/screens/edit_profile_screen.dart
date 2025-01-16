import 'package:flutter/material.dart';
import 'package:arabasatis/services/api_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileEditScreen({super.key, required this.userData});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.userData['Username']);
    _emailController = TextEditingController(text: widget.userData['Email']);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedData = {
          'Username': _usernameController.text,
          'Email': _emailController.text,
        };

        final response = await _apiService.updateProfile(updatedData);

        // Başarılı güncelleme sonrası geri dön ve yeni verileri yansıt
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['Message'])),
        );

        Navigator.pop(context, true); // Profil ekranına geri dön
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profili Düzenle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Kullanıcı Adı"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Kullanıcı adı boş bırakılamaz.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "E-posta"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "E-posta boş bırakılamaz.";
                  }                 
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text("Kaydet"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
