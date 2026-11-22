import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analiz.dart';
import 'ui_ortak.dart';

/// AB'nin zorunlu tuttuğu 14 alerjen grubu.
class Alerjen {
  final String id;
  final String ad;
  final IconData ikon;
  final List<String> anahtarlar;
  final List<String> haric;

  Alerjen(
    this.id,
    this.ad,
    this.ikon, {
    required List<String> anahtarlar,
    List<String> haric = const [],
  })  : anahtarlar = anahtarlar.map(norm).toList(),
        haric = haric.map(norm).toList();
}

final List<Alerjen> alerjenler = [
  Alerjen('gluten', 'Gluten (buğday, arpa, çavdar, yulaf)', Icons.grain_rounded, anahtarlar: [
    'gluten', 'bugday', 'arpa', 'cavdar', 'yulaf', 'malt', 'irmik', 'bulgur', 'kuskus', 'makarna',
    'seitan', 'wheat', 'barley', 'rye', 'oat', 'spelt', 'kamut', 'triticale', 'semolina',
  ], haric: [
    'karabugday', 'maltodekstrin', 'maltodextrin', 'maltitol', 'maltoz', 'maltose', 'buckwheat',
  ]),
  Alerjen('sut', 'Süt ve süt ürünleri', Icons.local_drink_rounded, anahtarlar: [
    'sut', 'laktoz', 'kazein', 'kasein', 'krema', 'kaymak', 'tereyag', 'yogurt', 'yoghurt', 'peynir',
    'lor', 'whey', 'milk', 'butter', 'cream', 'cheese', 'lactose', 'casein', 'kefir', 'ayran',
  ], haric: [
    'hindistan cevizi sut', 'kokos sut', 'badem sut', 'soya sut', 'yulaf sut', 'pirinc sut',
    'coconut milk', 'almond milk', 'soy milk', 'oat milk', 'kakao tereyag', 'cocoa butter',
    'kakao yagi', 'shea butter',
  ]),
  Alerjen('yumurta', 'Yumurta', Icons.egg_alt_rounded, anahtarlar: [
    'yumurta', 'egg', 'albumin', 'ovalbumin', 'lizozim', 'e1105', 'mayonez', 'mayonnaise',
  ], haric: ['yumurtasiz']),
  Alerjen('fistik', 'Yer fıstığı', Icons.lunch_dining_rounded, anahtarlar: [
    'yer fistig', 'yer fistik', 'fistik', 'fistig', 'peanut', 'groundnut',
  ], haric: ['antep fist']),
  Alerjen('kuruyemis', 'Sert kabuklu yemişler (fındık, badem, ceviz...)', Icons.park_rounded, anahtarlar: [
    'findik', 'findig', 'badem', 'ceviz', 'kaju', 'antep fist', 'pistachio', 'pekan', 'macadamia',
    'hazelnut', 'almond', 'walnut', 'cashew', 'pecan', 'fistik ezmesi',
  ], haric: ['hindistan ceviz', 'coconut']),
  Alerjen('soya', 'Soya', Icons.eco_rounded, anahtarlar: [
    'soya', 'soja', 'soy', 'lesitin', 'lecithin', 'e322',
  ], haric: ['aycicegi lesitin', 'aycicek lesitin', 'sunflower lecithin', 'sunflower lecithin']),
  Alerjen('balik', 'Balık', Icons.set_meal_rounded, anahtarlar: [
    'balik', 'fish', 'somon', 'hamsi', 'sardalya', 'anchovy', 'salmon', 'tuna', 'morina', 'cod',
  ]),
  Alerjen('kabuklu', 'Kabuklu deniz ürünleri', Icons.ramen_dining_rounded, anahtarlar: [
    'karides', 'yengec', 'istakoz', 'kerevit', 'shrimp', 'crab', 'lobster', 'crustacean', 'kabuklu deniz',
  ]),
  Alerjen('yumusakca', 'Yumuşakçalar (midye, kalamar...)', Icons.rice_bowl_rounded, anahtarlar: [
    'midye', 'kalamar', 'ahtapot', 'istiridye', 'salyangoz', 'mollusc', 'mollusk', 'mussel', 'squid', 'octopus',
  ]),
  Alerjen('kereviz', 'Kereviz', Icons.spa_rounded, anahtarlar: ['kereviz', 'celery', 'celeriac']),
  Alerjen('hardal', 'Hardal', Icons.local_florist_rounded, anahtarlar: ['hardal', 'mustard']),
  Alerjen('susam', 'Susam', Icons.breakfast_dining_rounded, anahtarlar: ['susam', 'sesame', 'tahin', 'tahini']),
  Alerjen('sulfit', 'Sülfit / kükürt dioksit', Icons.science_rounded, anahtarlar: [
    'sulfit', 'sulphite', 'sulfite', 'kukurt dioksit', 'sulphur dioxide', 'sulfur dioxide',
    'e220', 'e221', 'e222', 'e223', 'e224', 'e225', 'e226', 'e227', 'e228',
  ]),
  Alerjen('lupin', 'Lupin (acı bakla)', Icons.grass_rounded, anahtarlar: ['lupin', 'acibakla']),
];

/// Parantez içi açıklaması olmayan kısa ad.
String kisaAd(Alerjen a) => a.ad.split(' (').first;

Alerjen? alerjenBul(String id) {
  for (final a in alerjenler) {
    if (a.id == id) return a;
  }
  return null;
}

enum AlerjenDurum { icerir, iz }

const List<String> _izIsaretleri = [
  'icerebilir', 'iz miktar', 'may contain', 'traces', 'ayni tesiste', 'ayni uretim', 'uretim hatti',
  'uretilmistir', 'paylasilan', 'capraz',
];

const List<String> _olumsuz = [
  'icermez', 'icermeyen', 'icermemektedir', 'glutensiz', 'gluten free', 'gluten-free', 'sutsuz',
  'yumurtasiz', 'dairy free', 'egg free', 'nut free', 'peanut free', 'soy free',
];

bool _eslesir(String n, String anahtar) {
  if (anahtar.length <= 5) {
    return RegExp('(^|[^a-z0-9])${RegExp.escape(anahtar)}').hasMatch(n);
  }
  return n.contains(anahtar);
}

/// Open Food Facts alerjen etiketlerini (en:milk gibi) kendi kimliklerimize çevirir.
const Map<String, String> _offEtiket = {
  'gluten': 'gluten',
  'milk': 'sut',
  'eggs': 'yumurta',
  'peanuts': 'fistik',
  'nuts': 'kuruyemis',
  'soybeans': 'soya',
  'fish': 'balik',
  'crustaceans': 'kabuklu',
  'molluscs': 'yumusakca',
  'celery': 'kereviz',
  'mustard': 'hardal',
  'sesame-seeds': 'susam',
  'sulphur-dioxide-and-sulphites': 'sulfit',
  'lupin': 'lupin',
};

Map<String, AlerjenDurum> offEtiketleri(List<String> kesin, List<String> iz) {
  final sonuc = <String, AlerjenDurum>{};
  for (final t in iz) {
    final id = _offEtiket[t.split(':').last];
    if (id != null) sonuc[id] = AlerjenDurum.iz;
  }
  for (final t in kesin) {
    final id = _offEtiket[t.split(':').last];
    if (id != null) sonuc[id] = AlerjenDurum.icerir;
  }
  return sonuc;
}

/// Metindeki alerjenleri bulur. Kuşkulu durumlarda "içerir" kabul edilir
/// (alerjide yanlış güvence vermek, fazla uyarmaktan daha risklidir).
Map<String, AlerjenDurum> alerjenTara(String ham) {
  final sonuc = <String, AlerjenDurum>{};
  if (ham.trim().isEmpty) return sonuc;

  var n = norm(ham.replaceAll(RegExp(r'\s+'), ' '));
  n = n.replaceAllMapped(
    RegExp(r'(^|[^a-z0-9])e[\s\-]?(\d{3,4})'),
    (m) => '${m[1]}e${m[2]}',
  );

  for (final cumle in n.split(RegExp(r'(?<!\d)\.(?!\d)'))) {
    final c = cumle.trim();
    if (c.isEmpty) continue;
    // Yalnızca kısa uyarı cümleleri "iz miktar" sayılır; uzun cümleler içindekiler listesi olabilir.
    final iz = c.length <= 120 && _izIsaretleri.any(c.contains);
    final parcalar = iz ? [c] : c.split(RegExp(r'[,;]'));

    for (final p in parcalar) {
      if (_olumsuz.any(p.contains)) continue;
      for (final a in alerjenler) {
        if (a.haric.any(p.contains)) continue;
        if (!a.anahtarlar.any((k) => _eslesir(p, k))) continue;
        if (iz) {
          sonuc.putIfAbsent(a.id, () => AlerjenDurum.iz);
        } else {
          sonuc[a.id] = AlerjenDurum.icerir;
        }
      }
    }
  }
  return sonuc;
}

/// Düzenlenen içindekiler metnine, orijinal etiketteki uyarı cümlelerini ("içerebilir" vb.) ekler.
String alerjenCumleleri(String ham) {
  final n = ham.replaceAll(RegExp(r'\s+'), ' ');
  final sec = <String>[];
  for (final c in n.split(RegExp(r'(?<!\d)\.(?!\d)'))) {
    final k = norm(c);
    if (k.contains('alerjen') || _izIsaretleri.any(k.contains)) sec.add(c.trim());
  }
  return sec.join('. ');
}

class AlerjiOzeti {
  final Seviye seviye;
  final String etiket;
  final Map<String, AlerjenDurum> bulunan;
  final List<Alerjen> seciliKesin;
  final List<Alerjen> seciliIz;
  final bool veriYok;
  final bool profilYok;

  const AlerjiOzeti({
    required this.seviye,
    required this.etiket,
    required this.bulunan,
    required this.seciliKesin,
    required this.seciliIz,
    required this.veriYok,
    required this.profilYok,
  });
}

AlerjiOzeti alerjiOzeti(String metin, Set<String> secili, Map<String, AlerjenDurum> ek) {
  final bulunan = Map<String, AlerjenDurum>.from(alerjenTara(metin));
  ek.forEach((id, d) {
    if (d == AlerjenDurum.icerir) {
      bulunan[id] = AlerjenDurum.icerir;
    } else {
      bulunan.putIfAbsent(id, () => AlerjenDurum.iz);
    }
  });

  final veriYok = metin.trim().isEmpty && ek.isEmpty;
  final kesin = <Alerjen>[];
  final iz = <Alerjen>[];
  for (final a in alerjenler) {
    if (!secili.contains(a.id)) continue;
    final d = bulunan[a.id];
    if (d == AlerjenDurum.icerir) kesin.add(a);
    if (d == AlerjenDurum.iz) iz.add(a);
  }

  Seviye s;
  String e;
  if (veriYok) {
    s = Seviye.bilinmiyor;
    e = 'Veri yok';
  } else if (secili.isEmpty) {
    s = Seviye.bilinmiyor;
    e = 'Profil yok';
  } else if (kesin.isNotEmpty) {
    s = Seviye.kotu;
    e = 'Uygun değil';
  } else if (iz.isNotEmpty) {
    s = Seviye.orta;
    e = 'Dikkat';
  } else {
    s = Seviye.iyi;
    e = 'Tespit yok';
  }

  return AlerjiOzeti(
    seviye: s,
    etiket: e,
    bulunan: bulunan,
    seciliKesin: kesin,
    seciliIz: iz,
    veriYok: veriYok,
    profilYok: secili.isEmpty,
  );
}

class AlerjiDeposu {
  static final ValueNotifier<Set<String>> secili = ValueNotifier<Set<String>>(<String>{});

  static Future<void> yukle() async {
    final p = await SharedPreferences.getInstance();
    secili.value = (p.getStringList('alerji_profili') ?? <String>[]).toSet();
  }

  static Future<void> degistir(String id, bool ac) async {
    final yeni = Set<String>.from(secili.value);
    if (ac) {
      yeni.add(id);
    } else {
      yeni.remove(id);
    }
    secili.value = yeni;
    final p = await SharedPreferences.getInstance();
    await p.setStringList('alerji_profili', yeni.toList());
  }
}

/// Ayarlar sekmesindeki alerji profili seçici.
class AlerjiSecici extends StatelessWidget {
  const AlerjiSecici({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Kart(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Renk.kotu.o(0.12), shape: BoxShape.circle),
                child: const Icon(Icons.health_and_safety_rounded, color: Renk.kotu, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Alerji profilim', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Alerjiniz olan maddeleri seçin. Taranan her üründe bu maddeler için özel uyarı gösterilir.',
            style: TextStyle(fontSize: 13, height: 1.4, color: cs.onSurface.o(0.65)),
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<Set<String>>(
            valueListenable: AlerjiDeposu.secili,
            builder: (context, secili, _) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in alerjenler)
                  FilterChip(
                    avatar: Icon(a.ikon, size: 18, color: secili.contains(a.id) ? Colors.white : Renk.ana),
                    label: Text(kisaAd(a)),
                    selected: secili.contains(a.id),
                    showCheckmark: false,
                    selectedColor: Renk.kotu,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: secili.contains(a.id) ? Colors.white : cs.onSurface,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (v) => AlerjiDeposu.degistir(a.id, v),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sonuç ekranındaki "Alerjisi olanlar için" kartı.
class AlerjiKarti extends StatelessWidget {
  final String metin;
  final Map<String, AlerjenDurum> ek;
  const AlerjiKarti({super.key, required this.metin, this.ek = const {}});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ValueListenableBuilder<Set<String>>(
      valueListenable: AlerjiDeposu.secili,
      builder: (context, secili, _) {
        final o = alerjiOzeti(metin, secili, ek);
        final renk = seviyeRengi(o.seviye);

        Widget satir(IconData i, Color c, String t) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: const EdgeInsets.only(top: 2), child: Icon(i, size: 17, color: c)),
                  const SizedBox(width: 9),
                  Expanded(child: Text(t, style: const TextStyle(fontSize: 13.5, height: 1.38))),
                ],
              ),
            );

        final tespit = <Widget>[];
        for (final a in alerjenler) {
          final d = o.bulunan[a.id];
          if (d == null) continue;
          final benim = secili.contains(a.id);
          final c = benim ? Renk.kotu : Renk.notr;
          tespit.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: d == AlerjenDurum.icerir ? c.o(0.14) : null,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: c.o(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(a.ikon, size: 15, color: c),
                  const SizedBox(width: 6),
                  Text(
                    '${kisaAd(a)}${d == AlerjenDurum.iz ? ' (iz)' : ''}',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c),
                  ),
                ],
              ),
            ),
          );
        }

        return Kart(
          kenar: renk.o(0.4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: renk.o(0.14), shape: BoxShape.circle),
                    child: Icon(Icons.health_and_safety_rounded, color: renk, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Alerjisi olanlar için', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(o.etiket, style: TextStyle(color: renk, fontWeight: FontWeight.w800, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (o.veriYok)
                satir(Icons.info_rounded, Renk.notr,
                    'Bu ürün için içerik bilgisi olmadığından alerjen kontrolü yapılamadı. Ambalajdaki alerjen uyarısını kontrol edin.')
              else ...[
                for (final a in o.seciliKesin) satir(Icons.cancel_rounded, Renk.kotu, '${kisaAd(a)} içeriyor.'),
                for (final a in o.seciliIz)
                  satir(Icons.warning_amber_rounded, Renk.orta, '${kisaAd(a)} iz miktarda bulunabilir (çapraz bulaşma).'),
                if (o.profilYok)
                  satir(Icons.info_rounded, Renk.notr,
                      'Alerji profilinizi Ayarlar sekmesinden seçerseniz size özel uyarı verilir.')
                else if (o.seciliKesin.isEmpty && o.seciliIz.isEmpty)
                  satir(Icons.check_circle_rounded, Renk.iyi,
                      'Seçtiğiniz alerjenler okunan içerik bilgisinde tespit edilmedi.'),
                if (tespit.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Üründe tespit edilen alerjenler',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: cs.onSurface.o(0.6))),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: tespit),
                ] else if (!o.profilYok)
                  const SizedBox.shrink(),
              ],
              const SizedBox(height: 10),
              Text(
                'Alerjen tespiti yalnızca okunan içerik metnine dayanır; çapraz bulaşma bilgisi eksik olabilir. '
                'Ciddi alerjiniz varsa her zaman ambalajdaki alerjen uyarısını esas alın.',
                style: TextStyle(fontSize: 11.5, height: 1.35, color: cs.onSurface.o(0.5)),
              ),
            ],
          ),
        );
      },
    );
  }
}
