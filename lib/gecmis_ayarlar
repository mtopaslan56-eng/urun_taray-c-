import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alerji.dart';
import 'ui_ortak.dart';

class ScannedProduct {
  final String barcode;
  final String name;
  final String status;
  final String imageUrl;
  final DateTime date;

  ScannedProduct({
    required this.barcode,
    required this.name,
    required this.status,
    required this.imageUrl,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'name': name,
        'status': status,
        'imageUrl': imageUrl,
        'date': date.toIso8601String(),
      };

  factory ScannedProduct.fromJson(Map<String, dynamic> json) => ScannedProduct(
        barcode: json['barcode'],
        name: json['name'],
        status: json['status'],
        imageUrl: json['imageUrl'],
        date: DateTime.parse(json['date']),
      );
}

class GecmisDeposu {
  static final ValueNotifier<int> degisti = ValueNotifier<int>(0);

  static Future<List<ScannedProduct>> oku() async {
    final prefs = await SharedPreferences.getInstance();
    final ham = prefs.getStringList('gecmis') ?? [];
    final liste = <ScannedProduct>[];
    for (final e in ham) {
      try {
        liste.add(ScannedProduct.fromJson(jsonDecode(e)));
      } catch (_) {
        // Bozuk kayıtları atla
      }
    }
    return liste;
  }

  static Future<void> ekle(ScannedProduct urun) async {
    final prefs = await SharedPreferences.getInstance();
    final gecmis = prefs.getStringList('gecmis') ?? [];
    gecmis.insert(0, jsonEncode(urun.toJson()));
    if (gecmis.length > 50) gecmis.removeLast();
    await prefs.setStringList('gecmis', gecmis);
    degisti.value++;
  }

  static Future<void> temizle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gecmis');
    degisti.value++;
  }
}

String _tarih(DateTime d) {
  String iki(int n) => n.toString().padLeft(2, '0');
  return '${iki(d.day)}.${iki(d.month)}.${d.year}  ${iki(d.hour)}:${iki(d.minute)}';
}

class GecmisSekmesi extends StatefulWidget {
  const GecmisSekmesi({super.key});

  @override
  State<GecmisSekmesi> createState() => _GecmisSekmesiState();
}

class _GecmisSekmesiState extends State<GecmisSekmesi> {
  List<ScannedProduct> _liste = [];

  @override
  void initState() {
    super.initState();
    _yukle();
    GecmisDeposu.degisti.addListener(_yukle);
  }

  @override
  void dispose() {
    GecmisDeposu.degisti.removeListener(_yukle);
    super.dispose();
  }

  Future<void> _yukle() async {
    final l = await GecmisDeposu.oku();
    if (!mounted) return;
    setState(() => _liste = l);
  }

  Future<void> _temizleSor() async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Geçmiş silinsin mi?'),
        content: const Text('Tüm tarama geçmişi kalıcı olarak silinecek.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil')),
        ],
      ),
    );
    if (onay == true) await GecmisDeposu.temizle();
  }

  (Color, String) _durum(String status) {
    if (status.contains('ZARARLI')) return (Renk.kotu, status);
    if (status.contains('DİKKATLİ') || status.contains('RİSKLİ')) return (Renk.orta, status);
    if (status.contains('VERİ')) return (Renk.notr, status);
    return (Renk.iyi, status);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş'),
        actions: [
          if (_liste.isNotEmpty)
            IconButton(
              tooltip: 'Geçmişi temizle',
              onPressed: _temizleSor,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: _liste.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_rounded, size: 64, color: cs.onSurface.o(0.25)),
                    const SizedBox(height: 14),
                    Text(
                      'Henüz bir şey taramadınız.\nTarama yaptıkça sonuçlar burada listelenir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurface.o(0.6), height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: _liste.length,
              itemBuilder: (context, index) {
                final urun = _liste[index];
                final (renk, etiket) = _durum(urun.status);
                final etiketMi = urun.barcode == 'etiket';
                return Kart(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: cs.onSurface.o(0.06),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: urun.imageUrl.isNotEmpty
                              ? Image.network(
                                  urun.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Icon(Icons.image_outlined, color: cs.onSurface.o(0.35)),
                                )
                              : Icon(
                                  etiketMi ? Icons.document_scanner_outlined : Icons.image_outlined,
                                  color: cs.onSurface.o(0.35),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              urun.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(_tarih(urun.date), style: TextStyle(fontSize: 12, color: cs.onSurface.o(0.55))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: renk.o(0.13), borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          etiket,
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: renk),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class AyarlarSekmesi extends StatelessWidget {
  final bool koyuMod;
  final ValueChanged<bool> onDegisti;

  const AyarlarSekmesi({super.key, required this.koyuMod, required this.onDegisti});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Kart(
            child: Row(
              children: [
                Icon(Icons.dark_mode_rounded, color: cs.primary),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Karanlık mod', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      SizedBox(height: 2),
                      Text('Göz yormayan karanlık tema', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                Switch(value: koyuMod, onChanged: onDegisti),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const AlerjiSecici(),
          const SizedBox(height: 12),
          Kart(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: cs.primary),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sağlık Tarayıcı v2.5', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      SizedBox(height: 6),
                      Text(
                        'Barkod okutarak ya da etiketin fotoğrafını çekerek ürün içeriğini analiz eder; '
                        'sporcular, kilo vermek isteyenler ve alerjisi olanlar için uygunluğu değerlendirir.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Kart(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.health_and_safety_outlined, color: cs.primary),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Değerlendirmeler bilgilendirme amaçlıdır ve tıbbi tavsiye yerine geçmez. '
                    'Alerjiniz veya sağlık sorununuz varsa ürün etiketini ve doktorunuzu esas alın.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
