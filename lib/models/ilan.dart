class Ilan {
  final int? arabaId;  // 'id' yerine 'ArabaId' eklendi
  final String marka;
  final String model;
  final int yil;
  final double fiyat;
  final int kilometre;
  final String yakitTuru;
  final String vitesTuru;
  final String kasaTuru;
  final double motorHacmi;
  final String renk;
  final String telefon;
  final String aciklama;
  final List<Map<String, dynamic>>? fotografListesi;
  final String kayitTarihi;
  final int onay;

  Ilan({
    this.arabaId,  // 'id' yerine 'arabaId' kullanıldı
    required this.marka,
    required this.model,
    required this.yil,
    required this.fiyat,
    required this.kilometre,
    required this.yakitTuru,
    required this.vitesTuru,
    required this.kasaTuru,
    required this.motorHacmi,
    required this.renk,
    required this.telefon,
    required this.aciklama,
    this.fotografListesi,
    required this.kayitTarihi,
    required this.onay,
  });

  // JSON'a dönüştürme fonksiyonu
  Map<String, dynamic> toJson() {
    return {
      'ArabaId': arabaId,  // 'id' yerine 'ArabaId' ekledik
      'Marka': marka,
      'Model': model,
      'Yil': yil,
      'Fiyat': fiyat,
      'Kilometre': kilometre,
      'YakitTuru': yakitTuru,
      'VitesTuru': vitesTuru,
      'KasaTuru': kasaTuru,
      'MotorHacmi': motorHacmi,
      'Renk': renk,
      'Telefon':telefon,
      'Aciklama': aciklama,
      'FotografListesi': fotografListesi?.map((fotograf) => {
        'Fotograf':fotograf['Fotograf'],
        'FotografUrl': fotograf['FotografUrl'],
        'varsayilanFoto': fotograf['varsayilanFoto'],
        'kayitTarihi': fotograf['kayitTarihi'],
      }).toList(),
      'KayitTarihi': kayitTarihi,
      'Onay': onay,
    };
  }

  // JSON'dan dönüşüm fonksiyonu
  factory Ilan.fromJson(Map<String, dynamic> json) {
    return Ilan(
      arabaId: json['ArabaId'],  // 'id' yerine 'ArabaId' kullanıldı
      marka: json['Marka'],
      model: json['Model'],
      yil: json['Yil'],
      fiyat: json['Fiyat'].toDouble(),
      kilometre: json['Kilometre'],
      yakitTuru: json['YakitTuru'],
      vitesTuru: json['VitesTuru'],
      kasaTuru: json['KasaTuru'],
      motorHacmi: json['MotorHacmi'],
      renk: json['Renk'],
      telefon: json['Telefon'],
      aciklama: json['Aciklama'],
      fotografListesi: (json['FotografListesi'] as List?)?.map((fotograf) => {
        'Fotograf':fotograf['Fotograf'],
        'FotografUrl': fotograf['FotografUrl'],
        'varsayilanFoto': fotograf['varsayilanFoto'],
        'kayitTarihi': fotograf['kayitTarihi'],
      }).toList(),
      kayitTarihi: json['KayitTarihi'],
      onay: json['Onay'],
    );
  }
}
