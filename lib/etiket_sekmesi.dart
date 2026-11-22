import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'alerji.dart';
import 'analiz.dart';
import 'gecmis_ayarlar.dart';
import 'sonuc_gorunumu.dart';
import 'ui_ortak.dart';

/// Etiketteki besin değerleri tablosundan (100 g başına) değerleri ayıklar.
/// Tablo başlığı bulunamazsa null döner (içindekiler listesindeki sayıların
/// yanlışlıkla besin değeri sanılmasını önlemek için).
Besin? besinCikar(String ham) {
  final n = norm(ham).replaceAll(RegExp(r'\s+'), ' ');

  var bas = -1;
  for (final isaret in ['besin deger', 'besin ogesi', 'nutrition', 'ortalama', 'enerji', 'energy']) {
    final i = n.indexOf(isaret);
    if (i >= 0 && (bas < 0 || i < bas)) bas = i;
  }
  if (bas < 0) return null;
  final tablo = n.substring(bas);

  const sayi = r'(\d{1,3}(?:[.,]\d{1,2})?)';

  double? bul(String desen, {double maks = 100}) {
    final m = RegExp(desen).firstMatch(tablo);
    if (m == null) return null;
    final v = double.tryParse(m.group(1)!.replaceAll(',', '.'));
    if (v == null || v < 0 || v > maks) return null;
    return v;
  }

  final kcal = bul(r'(\d{2,4}(?:[.,]\d)?)\s*kcal', maks: 900);
  final seker = bul(r'seker\w*[^0-9]{0,15}?' + sayi + r'\s*g(?![a-z])');
  final yag = bul(r'(?<!doymus )(?<!doymamis )(?<!tekli )(?<!coklu )yag\w*[^0-9]{0,15}?' + sayi + r'\s*g(?![a-z])');
  final doymus = bul(r'doymus\s*yag\w*[^0-9]{0,15}?' + sayi + r'\s*g(?![a-z])');
  final protein = bul(r'protein\w*[^0-9]{0,15}?' + sayi + r'\s*g(?![a-z])');
  final lif = bul(r'lif\w*[^0-9]{0,15}?' + sayi + r'\s*g(?![a-z])');
  final tuz = bul(r'tuz\w*[^0-9]{0,15}?' + sayi + r'\s*g(?![a-z])');

  final b = Besin(kcal: kcal, seker: seker, yag: yag, doymusYag: doymus, protein: protein, lif: lif, tuz: tuz);
  return b.bos ? null : b;
}

enum _Adim { bos, okunuyor, sonuc }

class EtiketSekmesi extends StatefulWidget {
  const EtiketSekmesi({super.key});

  @override
  State<EtiketSekmesi> createState() => _EtiketSekmesiState();
}

class _EtiketSekmesiState extends State<EtiketSekmesi> {
  final ImagePicker _secici = ImagePicker();
  final TextRecognizer _tanima = TextRecognizer(script: TextRecognitionScript.latin);
  final TextEditingController _duzenleme = TextEditingController();

  _Adim _adim = _Adim.bos;
  AnalizSonucu? _analiz;
  Besin? _besin;
  bool _baslikBulundu = true;
  String _ham = '';
  String _alerjiMetni = '';

  @override
  void dispose() {
    _tanima.close();
    _duzenleme.dispose();
    super.dispose();
  }

  void _mesaj(String m) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(m)));
  }

  void _sifirla() {
    setState(() {
      _adim = _Adim.bos;
      _analiz = null;
      _besin = null;
      _ham = '';
      _alerjiMetni = '';
      _duzenleme.clear();
    });
  }

  Future<void> _fotografAl(ImageSource kaynak) async {
    try {
      final dosya = await _secici.pickImage(source: kaynak, imageQuality: 92, maxWidth: 2600);
      if (dosya == null) return;
      if (!mounted) return;
      setState(() => _adim = _Adim.okunuyor);

      final okunan = await _tanima.processImage(InputImage.fromFilePath(dosya.path));
      if (!mounted) return;

      final ham = okunan.text.trim();
      if (ham.length < 8) {
        setState(() => _adim = _Adim.bos);
        _mesaj('Yazı okunamadı. Etiketi daha yakından ve aydınlık ortamda çekmeyi deneyin.');
        return;
      }
      await _degerlendir(ham);
    } catch (_) {
      if (!mounted) return;
      setState(() => _adim = _Adim.bos);
      _mesaj('Fotoğraf alınamadı. Kamera ve fotoğraf izinlerini kontrol edin.');
    }
  }

  Future<void> _degerlendir(String ham) async {
    final ayik = icindekilerBolumunuAyikla(ham);
    final besin = besinCikar(ham);
    final analiz = analizEt(ayik.metin, besin: besin);

    await GecmisDeposu.ekle(
      ScannedProduct(
        barcode: 'etiket',
        name: 'Etiket taraması',
        status: analiz.genelEtiket,
        imageUrl: '',
        date: DateTime.now(),
      ),
    );
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() {
      _duzenleme.text = ayik.metin;
      _besin = besin;
      _analiz = analiz;
      _ham = ham;
      _alerjiMetni = ham;
      _baslikBulundu = ayik.baslikBulundu;
      _adim = _Adim.sonuc;
    });
  }

  void _yenidenAnaliz() {
    FocusScope.of(context).unfocus();
    final metin = _duzenleme.text.trim();
    if (metin.isEmpty) {
      _mesaj('Analiz için içindekiler metni boş olamaz.');
      return;
    }
    setState(() {
      _analiz = analizEt(metin, besin: _besin);
      // Düzeltilen metne, etiketteki alerjen/iz uyarı cümleleri de eklenir.
      _alerjiMetni = '$metin. ${alerjenCumleleri(_ham)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_adim) {
      case _Adim.okunuyor:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Renk.ana),
              SizedBox(height: 18),
              Text('Etiket okunuyor…', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      case _Adim.sonuc:
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: SonucGorunumu(
            baslik: 'Etiket Analizi',
            kaynak: 'Fotoğraftan okundu',
            analiz: _analiz!,
            besin: _besin,
            alerjiMetni: _alerjiMetni,
            onYeni: _sifirla,
            yeniEtiketi: 'Yeni Etiket Oku',
            yeniIkon: Icons.document_scanner_rounded,
            onKapat: _sifirla,
            ekstra: _duzeltmeKarti(context),
          ),
        );
      case _Adim.bos:
        return _bosGorunum(context);
    }
  }

  Widget _duzeltmeKarti(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Kart(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: Renk.ana),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Okunan içindekiler metni',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _baslikBulundu
                ? 'Yazı tanıma hata yapmış olabilir. Yanlış okunan kelimeleri düzeltip yeniden analiz edebilirsiniz.'
                : '"İçindekiler" başlığı bulunamadığı için okunan tüm metin analiz edildi. '
                    'Sadece içindekiler kısmını bırakıp yeniden analiz ederseniz sonuç daha doğru olur.',
            style: TextStyle(fontSize: 13, height: 1.4, color: cs.onSurface.o(0.65)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _duzenleme,
            minLines: 4,
            maxLines: 10,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontSize: 14, height: 1.4),
            decoration: InputDecoration(
              filled: true,
              fillColor: cs.onSurface.o(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _yenidenAnaliz,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Düzelt ve yeniden analiz et'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bosGorunum(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroBaslik(
              ust: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white.o(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 36),
              ),
              baslik: 'Etiket Oku',
              altBaslik: 'Barkodu olmayan ya da veritabanında bulunmayan ürünlerin içindekiler listesini fotoğraflayın.',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuyukButon(
                    ikon: Icons.photo_camera_rounded,
                    baslik: 'Fotoğraf Çek',
                    altMetin: 'Etiketin içindekiler bölümünü çekin',
                    onTap: () => _fotografAl(ImageSource.camera),
                  ),
                  const SizedBox(height: 14),
                  BuyukButon(
                    ikon: Icons.photo_library_rounded,
                    baslik: 'Galeriden Seç',
                    altMetin: 'Daha önce çektiğiniz fotoğrafı kullanın',
                    renkler: const [Color(0xFF455A64), Color(0xFF78909C)],
                    onTap: () => _fotografAl(ImageSource.gallery),
                  ),
                  const SizedBox(height: 26),
                  const BolumBasligi('Daha iyi sonuç için'),
                  const SizedBox(height: 12),
                  _ipucu(cs, Icons.wb_sunny_outlined, 'Aydınlık ortamda, yansıma olmadan çekin.'),
                  _ipucu(cs, Icons.crop_free_rounded, '"İçindekiler" yazısı ve altındaki liste kadrajda net görünsün.'),
                  _ipucu(cs, Icons.straighten_rounded, 'Etiketi düz tutun; kıvrık ya da eğik çekimde okuma hataları artar.'),
                  _ipucu(cs, Icons.table_chart_outlined, 'Besin değerleri tablosu da fotoğrafta varsa kalori, protein, şeker gibi değerler de okunur.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ipucu(ColorScheme cs, IconData ikon, String metin) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Kart(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(ikon, color: Renk.ana, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(metin, style: TextStyle(fontSize: 13.5, height: 1.35, color: cs.onSurface.o(0.8))),
            ),
          ],
        ),
      ),
    );
  }
}
