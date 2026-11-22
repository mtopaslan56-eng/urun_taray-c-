import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'analiz.dart';
import 'gecmis_ayarlar.dart';
import 'servis.dart';
import 'sonuc_gorunumu.dart';
import 'tarama_ekrani.dart';
import 'ui_ortak.dart';

enum _Durum { bos, yukleniyor, sonuc }

class BarkodSekmesi extends StatefulWidget {
  const BarkodSekmesi({super.key});

  @override
  State<BarkodSekmesi> createState() => _BarkodSekmesiState();
}

class _BarkodSekmesiState extends State<BarkodSekmesi> {
  final TextEditingController _elle = TextEditingController();
  _Durum _durum = _Durum.bos;
  UrunBilgisi? _urun;
  AnalizSonucu? _analiz;

  @override
  void dispose() {
    _elle.dispose();
    super.dispose();
  }

  void _mesaj(String m) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(m)));
  }

  void _sifirla() {
    setState(() {
      _durum = _Durum.bos;
      _urun = null;
      _analiz = null;
    });
  }

  Future<void> _tara() async {
    final kod = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const TaramaEkrani()),
    );
    if (kod == null || !mounted) return;
    await _sorgula(kod);
  }

  Future<void> _elleAra() async {
    FocusScope.of(context).unfocus();
    final kod = _elle.text.trim();
    if (!RegExp(r'^\d{8,14}$').hasMatch(kod)) {
      _mesaj('GeÃ§erli bir barkod girin (8-14 rakam).');
      return;
    }
    await _sorgula(kod);
  }

  Future<void> _sorgula(String ham) async {
    final kod = ham.trim();
    if (!RegExp(r'^\d{6,14}$').hasMatch(kod)) {
      _mesaj('Bu bir Ã¼rÃ¼n barkodu deÄil. ÃrÃ¼nÃ¼n Ã¼zerindeki Ã§izgili barkodu okutun.');
      return;
    }
    setState(() => _durum = _Durum.yukleniyor);
    final sonuc = await UrunServisi.sorgula(kod);
    if (!mounted) return;

    final urun = sonuc.urun;
    if (urun == null) {
      setState(() => _durum = _Durum.bos);
      _mesaj(
        sonuc.baglantiHatasi
            ? 'BaÄlantÄ± hatasÄ±. Ä°nternet baÄlantÄ±nÄ±zÄ± kontrol edin.'
            : 'ÃrÃ¼n veritabanÄ±nda bulunamadÄ±. "Etiket" sekmesinden iÃ§indekiler bÃ¶lÃ¼mÃ¼nÃ¼ fotoÄraflayabilirsiniz.',
      );
      return;
    }

    final analiz = analizEt(urun.icerik, besin: urun.besin, nutriscore: urun.nutriscore, nova: urun.nova);
    await GecmisDeposu.ekle(
      ScannedProduct(
        barcode: kod,
        name: urun.ad,
        status: analiz.genelEtiket,
        imageUrl: urun.resimUrl ?? '',
        date: DateTime.now(),
      ),
    );
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() {
      _urun = urun;
      _analiz = analiz;
      _durum = _Durum.sonuc;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_durum) {
      case _Durum.yukleniyor:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Renk.ana),
              SizedBox(height: 18),
              Text('ÃrÃ¼n aranÄ±yorâ¦', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      case _Durum.sonuc:
        final urun = _urun!;
        final analiz = _analiz!;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: SonucGorunumu(
            baslik: urun.ad,
            resimUrl: urun.resimUrl,
            kaynak: urun.kaynak,
            analiz: analiz,
            besin: urun.besin,
            nutriscore: urun.nutriscore,
            nova: urun.nova,
            alerjiMetni: urun.icerik,
            ekAlerjen: urun.ekAlerjen,
            onYeni: _tara,
            onKapat: _sifirla,
          ),
        );
      case _Durum.bos:
        return _bosGorunum(context);
    }
  }

  Widget _bosGorunum(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeroBaslik(
              ust: AppLogo(size: 64, acik: true),
              baslik: 'SaÄlÄ±k TarayÄ±cÄ±',
              altBaslik: 'Barkodu okut; iÃ§indekileri saniyeler iÃ§inde deÄerlendirelim.',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuyukButon(
                    ikon: Icons.qr_code_scanner_rounded,
                    baslik: 'Barkod Tara',
                    altMetin: 'KamerayÄ± Ã¼rÃ¼nÃ¼n barkoduna doÄrultun',
                    onTap: _tara,
                  ),
                  const SizedBox(height: 22),
                  const BolumBasligi('Barkodu elle gir'),
                  const SizedBox(height: 12),
                  Kart(
                    padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _elle,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            maxLength: 14,
                            onSubmitted: (_) => _elleAra(),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                              hintText: 'Ãrn. 8690504000012',
                            ),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: _elleAra,
                          style: IconButton.styleFrom(backgroundColor: Renk.ana, foregroundColor: Colors.white),
                          icon: const Icon(Icons.search_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  const BolumBasligi('NasÄ±l Ã§alÄ±ÅÄ±r?'),
                  const SizedBox(height: 12),
                  _adim(cs, Icons.qr_code_2_rounded, '1. Tara', 'Barkodu okutun ya da elle yazÄ±n.'),
                  _adim(cs, Icons.manage_search_rounded, '2. Analiz', 'Ä°Ã§indekiler katkÄ± ve risk aÃ§Ä±sÄ±ndan taranÄ±r.'),
                  _adim(cs, Icons.verified_rounded, '3. SonuÃ§', 'Sporcular ve kilo vermek isteyenler iÃ§in uygunluÄu gÃ¶rÃ¼n.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adim(ColorScheme cs, IconData ikon, String baslik, String metin) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Kart(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Renk.ana.o(0.12), shape: BoxShape.circle),
              child: Icon(ikon, color: Renk.ana, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(metin, style: TextStyle(fontSize: 13, height: 1.3, color: cs.onSurface.o(0.65))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
