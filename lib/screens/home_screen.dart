import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ilan.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoggedIn = false;
  Map<String, dynamic>? userData;
  final ApiService _apiService = ApiService();
  List<Ilan> _ilanlar = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchIlanlar();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    setState(() {
      isLoggedIn = token != null;
    });
  }

  Future<void> _fetchIlanlar() async {
    try {
      final ilanlarData = await _apiService.Ilanlar();
      setState(() {
        _ilanlar = ilanlarData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: ${e.toString()}")),
      );
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    setState(() {
      isLoggedIn = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Başarıyla çıkış yapıldı.")),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Satıştaki Arabalar"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menü',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            if (!isLoggedIn)
              ListTile(
                leading: Icon(Icons.person_add),
                title: const Text('Kayıt Ol'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
              ),
            if (!isLoggedIn)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Giriş Yap'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ).then((_) => _checkLoginStatus());
                },
              ),
            if (isLoggedIn)
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profil'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        userData: userData ?? {},
                      ),
                    ),
                  );
                },
              ),
            if (isLoggedIn)
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Çıkış Yap'),
                onTap: _logout,
              ),
          ],
        ),
      ),
      body: _ilanlar.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _ilanlar.length,
              itemBuilder: (context, index) {
                final ilan = _ilanlar[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${ilan.marka} ${ilan.model}", style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text("Yıl: ${ilan.yil} | Fiyat: ${ilan.fiyat.toStringAsFixed(2)} TL", style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text("Kilometre: ${ilan.kilometre} km", style: const TextStyle(fontSize: 14)),
                        Text("Yakıt Türü: ${ilan.yakitTuru}", style: const TextStyle(fontSize: 14)),
                        Text("Vites Türü: ${ilan.vitesTuru}", style: const TextStyle(fontSize: 14)),
                        Text("Kasa Türü: ${ilan.kasaTuru}", style: const TextStyle(fontSize: 14)),
                        Text("Motor Hacmi: ${ilan.motorHacmi} L", style: const TextStyle(fontSize: 14)),
                        Text("Renk: ${ilan.renk}", style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        Text("Telefon: ${ilan.telefon}", style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        Text("Açıklama: ${ilan.aciklama}", style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        Text("Kayıt Tarihi: ${DateTime.parse(ilan.kayitTarihi).toLocal().toString().split(' ')[0]}", style: const TextStyle(fontSize: 14)),
                        Text("Onay Durumu: ${ilan.onay == 1 ? 'Onaylı' : 'Bekliyor'}", style: const TextStyle(fontSize: 14)),
                        if (ilan.fotografListesi != null && ilan.fotografListesi!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.network(
                              ilan.fotografListesi!.first['FotografUrl'] ?? '',
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Add the favorite button
            Row(
  mainAxisSize: MainAxisSize.min, // Yalnızca gerekli kadar yer kaplamasını sağlar
  children: [
    IconButton(
      icon: Icon(Icons.favorite_border),
      onPressed: () async {
        try {
          await _apiService.Favoriekle(ilan.arabaId!);  // Pass the car ID
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${ilan.marka} ${ilan.model} favorilere eklendi.")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Favoriye ekleme hatası: ${e.toString()}")),
          );
        }
      },
    ),
    Text('Favorilere Ekle'),
  ],
)
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
