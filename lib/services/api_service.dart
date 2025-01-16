import 'dart:convert';
import 'package:arabasatis/models/ilan.dart';
import 'package:arabasatis/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseRegisterUrl = 'https://localhost:44381/api/kullanici/register';
  static const String _baseLoginUrl = 'https://localhost:44381/api/kullanici/login';
  static const String _baseProfileUrl = 'https://localhost:44381/api/kullanici/getprofile';
  static const String _baseUpdateProfileUrl = 'https://localhost:44381/api/kullanici/updateprofile';
  static const String _baseDeleteAccountUrl = 'https://localhost:44381/api/kullanici/delete';
  static const String _baseAddIlanUrl = 'https://localhost:44381/api/araba/ekle';
  static const String _baseGetIlanlarUrl = 'https://localhost:44381/api/araclarim';
  static const String _baseAdminPanelUrl = 'https://localhost:44381/api/admin/panel';
  static const String _baseApproveCarUrl = 'https://localhost:44381/api/admin/approveCar'; // Onayla/Reddet API URL'si

  // Admin paneline erişim kontrolü
  Future<bool> checkAdminPanelAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("JWT token bulunamadı. Lütfen giriş yapın.");
    }

    final response = await http.get(
      Uri.parse(_baseAdminPanelUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Message'] == "Admin paneline başarılı şekilde erişildi.") {
        return true; // Admin erişimi başarılı
      } else {
        throw Exception("Admin erişimi sağlanamadı.");
      }
    } else if (response.statusCode == 401) {
      throw Exception("Yetkisiz erişim. Lütfen giriş yapın.");
    } else {
      throw Exception("Admin paneline erişim sağlanamadı.");
    }
  }

  // Onay bekleyen araçları al
  Future<List<Map<String, dynamic>>> getPendingCars() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("JWT token bulunamadı. Lütfen giriş yapın.");
    }

    final response = await http.get(
      Uri.parse('https://localhost:44381/api/admin/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['Data']);
    } else {
      throw Exception("Onay bekleyen araba bulunamadı.");
    }
  }

  // Araba onayla veya reddet
  Future<String> updateCarStatus(int carId, int status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("JWT token bulunamadı. Lütfen giriş yapın.");
    }

    final response = await http.post(
      Uri.parse(_baseApproveCarUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'carId': carId, 'status': status}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Message'];
    } else {
      throw Exception("Araç durumu güncellenemedi.");
    }
  }

  // Kullanıcı kayıt işlemi
  Future<String> registerUser(User user) async {
    final response = await http.post(
      Uri.parse(_baseRegisterUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['Message'];
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? "Kayıt başarısız.");
    }
  }

  // Kullanıcı giriş işlemi
  Future<String> loginUser({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse(_baseLoginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Email': email,
        'PasswordHash': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['Data']['Token'];

      // Token'ı kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);

      return data['Message'];
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? "Giriş başarısız.");
    }
  }

  // Kullanıcı çıkış işlemi
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // Kullanıcı profil bilgilerini alma işlemi
  Future<Map<String, dynamic>> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("JWT token bulunamadı. Lütfen giriş yapın.");
    }

    final response = await http.get(
      Uri.parse(_baseProfileUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Data']; // Kullanıcı bilgileri döndürülüyor
    } else if (response.statusCode == 401) {
      throw Exception("Yetkisiz erişim. Lütfen giriş yapın.");
    } else {
      throw Exception("Profil bilgileri alınamadı.");
    }
  }

  // Kullanıcı profilini güncelleme işlemi
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updatedData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("JWT token bulunamadı. Lütfen giriş yapın.");
    }

    final response = await http.put(
      Uri.parse(_baseUpdateProfileUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Yeni token'i kaydet
      final newToken = data['NewToken'];
      await prefs.setString('jwt_token', newToken);

      return {
        'Message': data['Message'],
        'NewToken': newToken,
      };
    } else if (response.statusCode == 401) {
      throw Exception("Yetkisiz erişim. Lütfen giriş yapın.");
    } else {
      throw Exception(jsonDecode(response.body)['Message'] ?? "Profil güncellemesi başarısız.");
    }
  }

  // Kullanıcı hesabını silme işlemi
  Future<String> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("JWT token bulunamadı. Lütfen giriş yapın.");
    }

    final response = await http.delete(
      Uri.parse(_baseDeleteAccountUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Hesap silindikten sonra JWT token'ı temizle
      await prefs.remove('jwt_token');
      return jsonDecode(response.body)['Message'];
    } else if (response.statusCode == 401) {
      throw Exception("Yetkisiz erişim. Lütfen giriş yapın.");
    } else {
      throw Exception(jsonDecode(response.body)['Message'] ?? "Hesap silme işlemi başarısız.");
    }
  }

  // İlan verme işlemi
  Future<String> addIlan(Ilan ilan) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("JWT token bulunamadı. Lütfen giriş yapın.");
    }

    final response = await http.post(
      Uri.parse(_baseAddIlanUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(ilan.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['Message']; // Başarılı mesajını döndürür
    } else if (response.statusCode == 401) {
      throw Exception("Yetkisiz erişim. Lütfen giriş yapın.");
    } else {
      throw Exception(jsonDecode(response.body)['Message'] ?? "İlan verme işlemi başarısız.");
    }
  }

  // Kullanıcının ilanlarını listeleme işlemi
  Future<List<Ilan>> getIlanlar() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("JWT token bulunamadı. Lütfen giriş yapın.");
    }

    final response = await http.get(
      Uri.parse(_baseGetIlanlarUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Ilan>.from(data['Data'].map((x) => Ilan.fromJson(x)));
    } else {
      throw Exception("İlanlar alınamadı.");
    }
  }
  // Arabaları listeleme işlemi
// ignore: non_constant_identifier_names
Future<List<Ilan>> Ilanlar() async {

    final response = await http.get(
      Uri.parse('https://localhost:44381/api/araba/listele'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Ilan>.from(data['Data'].map((x) => Ilan.fromJson(x)));
    } else {
      throw Exception("İlanlar alınamadı.");
    }
  }
  // ignore: non_constant_identifier_names
  Future<List<Ilan>> favoriler() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("JWT token bulunamadı. Lütfen giriş yapın.");
    }

    final response = await http.get(
      Uri.parse('https://localhost:44381/api/favorilerim'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Ilan>.from(data['Data'].map((x) => Ilan.fromJson(x)));
    } else {
      throw Exception("İlanlar alınamadı.");
    }
  }
  // ignore: non_constant_identifier_names
  Future<String> DeleteMyCar(int carId,) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("JWT token bulunamadı. Lütfen giriş yapın.");
    }

    final response = await http.delete(
      Uri.parse('https://localhost:44381/api/deleteCar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'carId': carId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Message'];
    } else {
      throw Exception("Araç durumu güncellenemedi.");
    }
  }
  // ignore: non_constant_identifier_names
  Future<String> Favoriekle(int carId,) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("JWT token bulunamadı. Lütfen giriş yapın.");
    }

    final response = await http.delete(
      Uri.parse('https://localhost:44381/api/araba/favorilereEkle'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'carId': carId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Message'];
    } else {
      throw Exception("Araç durumu güncellenemedi.");
    }
  }


}
