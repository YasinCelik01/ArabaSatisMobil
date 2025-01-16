import 'package:arabasatis/screens/admin_panel_screen.dart';
import 'ilan_ver_screen.dart';
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'package:arabasatis/services/api_service.dart';
import 'araclarim_screen.dart'; // Araçlarım sayfasını ekliyoruz.
import 'favorites_screen.dart'; // Favoriler sayfasını ekliyoruz.

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required Map<String, dynamic> userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  Future<void> _fetchUserData() async {
    try {
      final data = await _apiService.fetchProfile();
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı bilgileri alınamadı: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hesabı Sil"),
          content: const Text(
              "Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Sil",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        final message = await _apiService.deleteAccount();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profil"),
        ),
        body: const Center(
          child: Text("Kullanıcı bilgileri alınamadı."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Ad: ${userData!['Username'] ?? 'Bilinmiyor'}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Email: ${userData!['Email'] ?? 'Bilinmiyor'}",
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Role: ${userData!['Role'] ?? 'Bilinmiyor'}",
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileEditScreen(
                      userData: userData!,
                    ),
                  ),
                );
              },
              child: const Text("Profili Düzenle"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _deleteAccount(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Hesabımı Sil"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddListingPage(),
                  ),
                );
              },
              child: const Text("İlan Ver"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AraclarimScreen(),
                  ),
                );
              },
              child: const Text("Araçlarım"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesScreen(),
                  ),
                );
              },
              child: const Text("Favorilerim"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
            ),
            const SizedBox(height: 20),
            if (userData!['Role'] == 'admin') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminPanelScreen(),
                    ),
                  );
                },
                child: const Text("Admin Panel"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
