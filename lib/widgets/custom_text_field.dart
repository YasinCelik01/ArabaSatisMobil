import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType keyboardType; // Opsiyonel hale getirildi.
  final FormFieldValidator<String>? validator; // Validator parametresi eklendi

  const CustomTextField({
    Key? key,
    required this.hintText,
    this.isPassword = false,
    required this.controller,
    this.keyboardType = TextInputType.text, // Varsayılan bir değer atandı.
    this.validator, // Validator parametresi opsiyonel olarak eklendi
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType, // Burada kullanılıyor.
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: validator, // Validator burada kullanılıyor
    );
  }
}
