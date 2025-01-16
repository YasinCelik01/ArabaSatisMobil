import 'package:flutter/material.dart';
import 'package:arabasatis/services/api_service.dart'; // API servisini import ettik
// shared_preferences kullanıyoruz
import 'package:arabasatis/models/ilan.dart'; // Ilan modelini import ettik

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Ilan>> futureFavoriler;

  @override
  void initState() {
    super.initState();
    // favoriler fonksiyonunu çağırıyoruz ve sonucu futureFavoriler'e atıyoruz.
    futureFavoriler = ApiService().favoriler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorilerim'),
      ),
      body: FutureBuilder<List<Ilan>>(
        future: futureFavoriler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Veriler yüklenirken loading göstermek
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Hata oluşursa bir hata mesajı göstermek
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Favori ilan yoksa bir mesaj göstermek
            return Center(child: Text('Favori ilanınız yok.'));
          } else {
            // Favori ilanları listelemek
            final ilanlar = snapshot.data!;
            return ListView.builder(
              itemCount: ilanlar.length,
              itemBuilder: (context, index) {
                final ilan = ilanlar[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(Icons.favorite, color: Colors.red),
                    title: Text('${ilan.marka} ${ilan.model}'),
                    subtitle: Text(
                      'Yıl: ${ilan.yil}\n'
                      'Fiyat: ${ilan.fiyat} TL\n'
                      'Kilometre: ${ilan.kilometre} km\n'
                      'Yakıt: ${ilan.yakitTuru} | Vites: ${ilan.vitesTuru}\n'
                      'Renk: ${ilan.renk}\n'
                      'Telefon: ${ilan.telefon}\n'
                      'Açıklama: ${ilan.aciklama}',
                    ),
                    isThreeLine: true, // Üç satır gösterilecek
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      // İlanın detaylarına yönlendirme yapılabilir
                      // Navigator.push(...); 
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
