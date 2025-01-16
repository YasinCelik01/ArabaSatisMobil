import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = User(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      final message = await _apiService.registerUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      // Register işleminden sonra login sayfasına yönlendirme
      Navigator.pushReplacementNamed(context, '/login');  // Burada '/login' rotasına yönlendirme yapıyoruz
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(        
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,                  
                  ),
                ),
                SizedBox(height: 20),
                CustomTextField(
                  hintText: "Username",
                  controller: _usernameController,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  hintText: "Email",
                  controller: _emailController,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  hintText: "Password",
                  isPassword: true,
                  controller: _passwordController,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : CustomButton(
                        text: "Register",
                        onPressed: _register,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
