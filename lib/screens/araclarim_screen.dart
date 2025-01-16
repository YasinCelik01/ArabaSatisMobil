import 'package:flutter/material.dart';
import 'package:arabasatis/models/ilan.dart';
import 'package:arabasatis/services/api_service.dart';

class AraclarimScreen extends StatefulWidget {
  @override
  _AraclarimScreenState createState() => _AraclarimScreenState();
}

class _AraclarimScreenState extends State<AraclarimScreen> {
  final ApiService _apiService = ApiService();
  List<Ilan> _ilanlar = [];

  @override
  void initState() {
    super.initState();
    _fetchIlanlar();
  }

  Future<void> _fetchIlanlar() async {
    try {
      final ilanlarData = await _apiService.getIlanlar(); // API'den ilanları çekiyoruz.
      setState(() {
        _ilanlar = ilanlarData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: ${e.toString()}")));
    }
  }

  Future<void> _deleteIlan(int carId) async {
    try {
      await _apiService.DeleteMyCar(carId);  // Araba silme işlemi
      setState(() {
        _ilanlar.removeWhere((ilan) => ilan.arabaId == carId);  // Silinen aracı listeden çıkarıyoruz
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Araç başarıyla silindi.")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Araçlarım"),
      ),
      body: _ilanlar.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _ilanlar.length,
              itemBuilder: (context, index) {
                final ilan = _ilanlar[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${ilan.marka} ${ilan.model}", style: Theme.of(context).textTheme.titleLarge),
                        SizedBox(height: 8),
                        Text("Yıl: ${ilan.yil} | Fiyat: ${ilan.fiyat.toStringAsFixed(2)} TL", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        Text("Kilometre: ${ilan.kilometre} km", style: TextStyle(fontSize: 14)),
                        Text("Yakıtturu: ${ilan.yakitTuru}", style: TextStyle(fontSize: 14)),
                        Text("Vites Türü: ${ilan.vitesTuru}", style: TextStyle(fontSize: 14)),
                        Text("Kasa Türü: ${ilan.kasaTuru}", style: TextStyle(fontSize: 14)),
                        Text("Motor Hacmi: ${ilan.motorHacmi} L", style: TextStyle(fontSize: 14)),
                        Text("Renk: ${ilan.renk}", style: TextStyle(fontSize: 14)),
                        SizedBox(height: 8),
                        Text("Telefon:${ilan.telefon}", style: TextStyle(fontSize: 14)),
                        SizedBox(height: 8),
                        Text("Açıklama: ${ilan.aciklama}", style: TextStyle(fontSize: 14)),
                        SizedBox(height: 8),
                        Text("Kayit Tarihi: ${DateTime.parse(ilan.kayitTarihi).toLocal().toString().split(' ')[0]}", style: TextStyle(fontSize: 14)),
                        Text("Onay Durumu: ${ilan.onay == 1 ? 'Onaylı' : 'Bekliyor'}", style: TextStyle(fontSize: 14)),
                        // Fotoğraf gösterimi
                        if (ilan.fotografListesi != null && ilan.fotografListesi!.isNotEmpty) 
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.network(
                              ilan.fotografListesi!.first['FotografUrl'] ?? '', // İlk fotoğrafı al
                              height: 200,  // Fotoğraf boyutunu istediğiniz gibi ayarlayın
                              fit: BoxFit.cover,  // Resmi düzgün yerleştirmek için
                            ),
                          ),
                        SizedBox(height: 8),
                        ElevatedButton(
                         onPressed: ilan.arabaId != null ? () => _deleteIlan(ilan.arabaId!) : null,
                          child: const Text("Sil"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
