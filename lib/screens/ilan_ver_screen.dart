import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'package:arabasatis/models/ilan.dart';
import 'package:arabasatis/services/api_service.dart';
import 'package:flutter/foundation.dart';

class AddListingPage extends StatefulWidget {
  @override
  _AddListingPageState createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'marka': TextEditingController(),
    'model': TextEditingController(),
    'yil': TextEditingController(),
    'fiyat': TextEditingController(),
    'kilometre': TextEditingController(),
    'yakitTuru': TextEditingController(),
    'vitesTuru': TextEditingController(),
    'kasaTuru': TextEditingController(),
    'motorHacmi': TextEditingController(),
    'renk': TextEditingController(),
    'telefon':TextEditingController(),
    'aciklama': TextEditingController(),
  };

  List<Map<String, dynamic>> _fotografListesi = []; // Fotoğraf listesi, varsayılan ve tarih ile
  bool _varsayilanFoto = false; // Varsayılan fotoğraf durumu

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      if (kIsWeb) {
        final bytes = await pickedImage.readAsBytes();
        setState(() {
          _fotografListesi.add({
            'Fotograf': base64Encode(bytes),
            'VarsayilanFotograf': _varsayilanFoto,
            'kayitTarihi': DateTime.now().toIso8601String(),
          });
        });
      } else {
        final bytes = await pickedImage.readAsBytes();
        setState(() {
          _fotografListesi.add({
            'Fotograf': base64Encode(bytes),
            'VarsayilanFotograf': _varsayilanFoto,
            'kayitTarihi': DateTime.now().toIso8601String(),
          });
        });
      }
    }
  }

  Future<void> _submitListing() async {
    if (_formKey.currentState?.validate() ?? false) {
      final ilan = Ilan(
  marka: _controllers['marka']!.text,
  model: _controllers['model']!.text,
  yil: int.parse(_controllers['yil']!.text),
  fiyat: double.parse(_controllers['fiyat']!.text),
  kilometre: int.parse(_controllers['kilometre']!.text),
  yakitTuru: _controllers['yakitTuru']!.text,
  vitesTuru: _controllers['vitesTuru']!.text,
  kasaTuru: _controllers['kasaTuru']!.text,
  motorHacmi: double.parse(_controllers['motorHacmi']!.text),
  renk: _controllers['renk']!.text,
  telefon: _controllers['telefon']!.text,
  aciklama: _controllers['aciklama']!.text,
  fotografListesi: _fotografListesi,
  kayitTarihi: DateTime.now().toIso8601String(),  // Pass kayitTarihi
  onay: 0,  // You can set a default value or pass a dynamic value
);
      
      try {
        final apiService = ApiService();
        final responseMessage = await apiService.addIlan(ilan);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İlan Ver'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ..._controllers.entries.map((entry) {
                final field = entry.key;
                final controller = entry.value;

                return CustomTextField(
                  hintText: field[0].toUpperCase() + field.substring(1),
                  controller: controller,
                  keyboardType: field == 'yil' || field == 'fiyat' || field == 'kilometre'
                      ? TextInputType.number
                      : TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '$field gereklidir';
                    }
                    if ((field == 'yil' || field == 'kilometre') && int.tryParse(value) == null) {
                      return 'Geçerli bir sayı giriniz';
                    }
                    if (field == 'fiyat' && double.tryParse(value) == null) {
                      return 'Geçerli bir fiyat giriniz';
                    }
                    return null;
                  },
                );
              }).toList(),
              _fotografListesi.isEmpty
                  ? ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Resim Yükle'),
                    )
                  : Column(
                      children: [
                        for (var foto in _fotografListesi)
                          kIsWeb
                              ? Image.memory(
                                  base64Decode(foto['Fotograf']),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(foto['Fotograf']),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                      ],
                    ),
              SizedBox(height: 16),
              CustomButton(
                text: 'İlanı Gönder',
                onPressed: _submitListing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

