import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'alerji.dart';
import 'analiz.dart';
import 'ui_ortak.dart';

class SonucGorunumu extends StatelessWidget {
  final String baslik;
  final String? resimUrl;
  final String? kaynak;
  final AnalizSonucu analiz;
  final Besin? besin;
  final String? nutriscore;
  final int? nova;
  final VoidCallback onYeni;
  final String yeniEtiketi;
  final IconData yeniIkon;
  final VoidCallback? onKapat;
  final Widget? ekstra;
  final String? alerjiMetni;
  final Map<String, AlerjenDurum> ekAlerjen;

  const SonucGorunumu({
    super.key,
    required this.baslik,
    required this.analiz,
    required this.onYeni,
    this.resimUrl,
    this.kaynak,
    this.besin,
    this.nutriscore,
    this.nova,
    this.yeniEtiketi = 'Yeni ÃrÃ¼n Tara',
    this.yeniIkon = Icons.qr_code_scanner_rounded,
    this.onKapat,
    this.ekstra,
    this.alerjiMetni,
    this.ekAlerjen = const {},
  });

  /// YalnÄ±zca iÃ§indekiler listesine dayanan tahmini puan; genel seviyeyle tutarlÄ± tutulur.
  int? _puan() {
    if (analiz.genelSeviye == Seviye.bilinmiyor) return null;
    var p = 100 - analiz.yuksek * 25 - analiz.hafif * 10;
    p += analiz.bilesenler.where((b) => b.olumlu).length * 4;
    if (nutriscore != null) {
      p += switch (nutriscore) {
        'a' => 8,
        'b' => 4,
        'd' => -6,
        'e' => -12,
        _ => 0,
      };
    }
    p = math.min(100, math.max(0, p));
    return switch (analiz.genelSeviye) {
      Seviye.kotu => math.min(p, 39),
      Seviye.orta => math.min(math.max(p, 40), 69),
      _ => math.max(p, 70),
    };
  }

  @override
  Widget build(BuildContext context) {
    final b = besin;
    final riskli = analiz.yuksek + analiz.hafif;
    final cs = Theme.of(context).colorScheme;
    final besinVar = (b != null && !b.bos) || nutriscore != null || nova != null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _baslikAlani(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GirisAnim(sira: 0, child: _puanKarti(context)),
                const SizedBox(height: 12),
                GirisAnim(sira: 1, child: _hizliOzet(context)),
                const SizedBox(height: 18),
                if (riskli > 0) ...[
                  GirisAnim(sira: 2, child: _riskBandi(context)),
                  const SizedBox(height: 22),
                ],
                const GirisAnim(sira: 3, child: BolumBasligi('Kimler iÃ§in uygun?')),
                const SizedBox(height: 12),
                GirisAnim(
                  sira: 3,
                  child: ProfilKarti(ikon: Icons.fitness_center_rounded, baslik: 'Sporcular iÃ§in', profil: analiz.spor),
                ),
                const SizedBox(height: 12),
                GirisAnim(
                  sira: 4,
                  child: ProfilKarti(
                    ikon: Icons.monitor_weight_outlined,
                    baslik: 'Kilo vermek isteyenler iÃ§in',
                    profil: analiz.diyet,
                  ),
                ),
                const SizedBox(height: 12),
                GirisAnim(sira: 5, child: AlerjiKarti(metin: alerjiMetni ?? '', ek: ekAlerjen)),
                if (besinVar) ...[
                  const SizedBox(height: 26),
                  const GirisAnim(sira: 6, child: BolumBasligi('Besin deÄerleri')),
                  const SizedBox(height: 12),
                  GirisAnim(sira: 6, child: _besinAlani(context, b)),
                ],
                const SizedBox(height: 26),
                const BolumBasligi('Ä°Ã§indekiler ve etkileri'),
                const SizedBox(height: 12),
                if (analiz.bilesenler.isEmpty)
                  Kart(
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: cs.onSurface.o(0.5)),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('Bu Ã¼rÃ¼n iÃ§in iÃ§erik bilgisi bulunamadÄ±.')),
                      ],
                    ),
                  )
                else
                  ...analiz.bilesenler.map((x) => _bilesenKarti(context, x)),
                for (final n in analiz.notlar)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('â¢ $n', style: TextStyle(fontSize: 13, color: cs.onSurface.o(0.7), height: 1.35)),
                  ),
                if (ekstra != null) ...[
                  const SizedBox(height: 20),
                  ekstra!,
                ],
                const SizedBox(height: 20),
                Text(
                  'Bu deÄerlendirme yalnÄ±zca iÃ§indekiler listesine (ve varsa 100 g besin deÄerlerine) dayanan, '
                  'bilgilendirme amaÃ§lÄ± bir tahmindir; tÄ±bbi tavsiye deÄildir. Alerjiniz, hastalÄ±ÄÄ±nÄ±z veya Ã¶zel '
                  'bir diyetiniz varsa Ã¼rÃ¼n etiketini ve doktorunuzu esas alÄ±n.',
                  style: TextStyle(fontSize: 12, height: 1.4, color: cs.onSurface.o(0.55)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onYeni,
                    icon: Icon(yeniIkon),
                    label: Text(yeniEtiketi),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Renk.ana,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _puanKarti(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final puan = _puan();
    final renk = seviyeRengi(analiz.genelSeviye);
    final baslikMetni = switch (analiz.genelSeviye) {
      Seviye.iyi => 'Ä°Ã§eriÄi iyi gÃ¶rÃ¼nÃ¼yor',
      Seviye.orta => 'Dikkatli tÃ¼ketin',
      Seviye.kotu => 'Ä°Ã§eriÄi riskli',
      Seviye.bilinmiyor => 'DeÄerlendirme iÃ§in yeterli veri yok',
    };
    return Kart(
      child: Row(
        children: [
          if (puan != null) _PuanHalkasi(puan: puan, renk: renk) else Icon(Icons.help_outline_rounded, size: 56, color: renk),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslikMetni, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: renk)),
                const SizedBox(height: 4),
                Text(
                  puan != null
                      ? 'Ä°Ã§indekiler listesine gÃ¶re hesaplanan tahmini iÃ§erik puanÄ± (100 Ã¼zerinden).'
                      : 'Ä°Ã§erik ya da besin bilgisi bulunamadÄ±.',
                  style: TextStyle(fontSize: 12.5, height: 1.35, color: cs.onSurface.o(0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hizliOzet(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniOzet(
            ikon: Icons.fitness_center_rounded,
            ad: 'Sporcu',
            deger: analiz.spor.seviyeEtiketi,
            renk: seviyeRengi(analiz.spor.seviye),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniOzet(
            ikon: Icons.monitor_weight_outlined,
            ad: 'Diyet',
            deger: analiz.diyet.seviyeEtiketi,
            renk: seviyeRengi(analiz.diyet.seviye),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ValueListenableBuilder<Set<String>>(
            valueListenable: AlerjiDeposu.secili,
            builder: (context, secili, _) {
              final o = alerjiOzeti(alerjiMetni ?? '', secili, ekAlerjen);
              return _MiniOzet(
                ikon: Icons.health_and_safety_rounded,
                ad: 'Alerji',
                deger: o.etiket,
                renk: seviyeRengi(o.seviye),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _baslikAlani(BuildContext context) {
    final renk = seviyeRengi(analiz.genelSeviye);
    final resimVar = resimUrl != null && resimUrl!.isNotEmpty;
    final IconData seviyeIkonu = switch (analiz.genelSeviye) {
      Seviye.iyi => Icons.check_circle_rounded,
      Seviye.orta => Icons.warning_amber_rounded,
      Seviye.kotu => Icons.dangerous_rounded,
      Seviye.bilinmiyor => Icons.help_rounded,
    };
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 8, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [renk, Color.alphaBlend(Colors.black.o(0.22), renk)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [BoxShadow(color: renk.o(0.35), blurRadius: 22, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          if (onKapat != null)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onKapat,
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            )
          else
            const SizedBox(height: 12),
          Container(
            height: 148,
            width: 148,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: Colors.black.o(0.2), blurRadius: 22, offset: const Offset(0, 10))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: resimVar
                  ? Image.network(
                      resimUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag_outlined, size: 70, color: Colors.black26),
                    )
                  : const Icon(Icons.document_scanner_outlined, size: 70, color: Colors.black26),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            baslik,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.o(0.18), blurRadius: 12, offset: const Offset(0, 5))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(seviyeIkonu, color: renk, size: 20),
                const SizedBox(width: 8),
                Text(
                  analiz.genelEtiket,
                  style: TextStyle(color: renk, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ],
            ),
          ),
          if (kaynak != null) ...[
            const SizedBox(height: 10),
            Text(kaynak!, style: TextStyle(color: Colors.white.o(0.85), fontSize: 12.5)),
          ],
        ],
      ),
    );
  }

  Widget _riskBandi(BuildContext context) {
    final yuksekVar = analiz.yuksek > 0;
    final renk = yuksekVar ? Renk.kotu : Renk.orta;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final parcalar = <String>[];
    if (analiz.yuksek > 0) parcalar.add('${analiz.yuksek} yÃ¼ksek riskli');
    if (analiz.hafif > 0) parcalar.add('${analiz.hafif} dikkat edilmesi gereken');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: renk.o(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: renk.o(0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: renk, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ä°Ã§eriÄinde ${parcalar.join(' ve ')} madde bulundu. AyrÄ±ntÄ±lar aÅaÄÄ±da.',
              style: TextStyle(color: onSurface, fontWeight: FontWeight.w700, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _besinAlani(BuildContext context, Besin? b) {
    final kutular = <Widget>[];
    void kutuEkle(String ad, double? v, String birim) {
      if (v == null) return;
      final s = v.toStringAsFixed(v >= 10 ? 0 : 1).replaceAll(RegExp(r'\.0$'), '');
      kutular.add(_BesinKutusu(ad: ad, deger: '$s $birim'));
    }

    final trafik = <Widget>[];
    void trafikEkle(String ad, double? v, double dusuk, double yuksek) {
      if (v == null) return;
      trafik.add(_TrafikSatiri(ad: ad, deger: v, dusuk: dusuk, yuksek: yuksek));
    }

    if (b != null) {
      kutuEkle('Kalori', b.kcal, 'kcal');
      kutuEkle('Åeker', b.seker, 'g');
      kutuEkle('YaÄ', b.yag, 'g');
      kutuEkle('DoymuÅ yaÄ', b.doymusYag, 'g');
      kutuEkle('Protein', b.protein, 'g');
      kutuEkle('Lif', b.lif, 'g');
      kutuEkle('Tuz', b.tuz, 'g');

      trafikEkle('Åeker', b.seker, 5, 22.5);
      trafikEkle('YaÄ', b.yag, 3, 17.5);
      trafikEkle('DoymuÅ yaÄ', b.doymusYag, 1.5, 5);
      trafikEkle('Tuz', b.tuz, 0.3, 1.5);
    }

    const nutriRenkleri = {
      'a': Color(0xFF1E8F4E),
      'b': Color(0xFF7AC547),
      'c': Color(0xFFF2C230),
      'd': Color(0xFFF08A24),
      'e': Color(0xFFE5484D),
    };
    final cs = Theme.of(context).colorScheme;

    return Kart(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kutular.isNotEmpty) ...[
            Text('100 g baÅÄ±na', style: TextStyle(fontSize: 12.5, color: cs.onSurface.o(0.6))),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 10, children: kutular),
          ],
          if (trafik.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'DÃ¼ÅÃ¼k / orta / yÃ¼ksek (100 g iÃ§in yaygÄ±n eÅiklere gÃ¶re)',
              style: TextStyle(fontSize: 12.5, color: cs.onSurface.o(0.6)),
            ),
            const SizedBox(height: 10),
            ...trafik,
          ],
          if (nutriscore != null || nova != null) ...[
            if (kutular.isNotEmpty) const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                if (nutriscore != null)
                  _Rozet(
                    metin: 'Nutri-Score ${nutriscore!.toUpperCase()}',
                    renk: nutriRenkleri[nutriscore] ?? Renk.notr,
                  ),
                if (nova != null)
                  _Rozet(
                    metin: 'NOVA $nova',
                    renk: nova == 4 ? Renk.kotu : (nova == 3 ? Renk.orta : Renk.iyi),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _bilesenKarti(BuildContext context, Bilesen b) {
    final cs = Theme.of(context).colorScheme;
    final Color renk;
    final IconData ikon;
    if (b.risk == 2) {
      renk = Renk.kotu;
      ikon = Icons.dangerous_rounded;
    } else if (b.risk == 1) {
      renk = Renk.orta;
      ikon = Icons.warning_amber_rounded;
    } else if (b.olumlu) {
      renk = Renk.iyi;
      ikon = Icons.check_circle_rounded;
    } else {
      renk = Renk.notr;
      ikon = Icons.circle_outlined;
    }
    final aciklamali = b.eslesenler.where((m) => m.risk > 0 || m.olumlu).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: b.risk > 0 || b.olumlu ? renk.o(0.09) : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: b.risk > 0 || b.olumlu ? renk.o(0.3) : cs.outlineVariant.o(0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: renk, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.metin,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: b.risk > 0 ? FontWeight.w700 : FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                for (final m in aciklamali)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      m.aciklama +
                          ((m.siraHassas && m.risk == 1 && b.risk == 2)
                              ? ' Listenin ilk sÄ±ralarÄ±nda yer aldÄ±ÄÄ± iÃ§in Ã¼rÃ¼nde yÃ¼ksek oranda bulunuyor.'
                              : ''),
                      style: TextStyle(fontSize: 13.5, height: 1.4, color: cs.onSurface.o(0.75)),
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

class ProfilKarti extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final Profil profil;
  const ProfilKarti({super.key, required this.ikon, required this.baslik, required this.profil});

  @override
  Widget build(BuildContext context) {
    final renk = seviyeRengi(profil.seviye);
    final cs = Theme.of(context).colorScheme;

    Widget satir(IconData i, Color c, String metin) => Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(top: 2), child: Icon(i, size: 17, color: c)),
              const SizedBox(width: 9),
              Expanded(child: Text(metin, style: const TextStyle(fontSize: 13.5, height: 1.38))),
            ],
          ),
        );

    final listeVar = profil.iyi.isNotEmpty || profil.kotu.isNotEmpty || profil.notlar.isNotEmpty;

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
                child: Icon(ikon, color: renk, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(baslik, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(profil.seviyeEtiketi, style: TextStyle(color: renk, fontWeight: FontWeight.w800, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          if (profil.ozet.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(profil.ozet, style: TextStyle(fontSize: 14, height: 1.35, color: cs.onSurface.o(0.85))),
          ],
          if (listeVar) const SizedBox(height: 12),
          for (final s in profil.iyi) satir(Icons.check_circle_rounded, Renk.iyi, s),
          for (final s in profil.kotu) satir(Icons.cancel_rounded, Renk.kotu, s),
          for (final s in profil.notlar) satir(Icons.info_rounded, Renk.notr, s),
        ],
      ),
    );
  }
}

class _PuanHalkasi extends StatelessWidget {
  final int puan;
  final Color renk;
  const _PuanHalkasi({required this.puan, required this.renk});

  @override
  Widget build(BuildContext context) {
    final zemin = Theme.of(context).colorScheme.onSurface.o(0.1);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: puan / 100),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        width: 84,
        height: 84,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(size: const Size.square(84), painter: _HalkaCizici(v, renk, zemin)),
            Text(
              '${(v * 100).round()}',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: renk),
            ),
          ],
        ),
      ),
    );
  }
}

class _HalkaCizici extends CustomPainter {
  final double oran;
  final Color renk;
  final Color zemin;
  const _HalkaCizici(this.oran, this.renk, this.zemin);

  @override
  void paint(Canvas canvas, Size size) {
    final merkez = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 7;
    final rect = Rect.fromCircle(center: merkez, radius: r);
    canvas.drawCircle(
      merkez,
      r,
      Paint()
        ..color = zemin
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * oran,
      false,
      Paint()
        ..color = renk
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _HalkaCizici eski) => eski.oran != oran || eski.renk != renk;
}

class _TrafikSatiri extends StatelessWidget {
  final String ad;
  final double deger;
  final double dusuk;
  final double yuksek;
  const _TrafikSatiri({required this.ad, required this.deger, required this.dusuk, required this.yuksek});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color renk;
    final String etiket;
    if (deger <= dusuk) {
      renk = Renk.iyi;
      etiket = 'DÃ¼ÅÃ¼k';
    } else if (deger <= yuksek) {
      renk = Renk.orta;
      etiket = 'Orta';
    } else {
      renk = Renk.kotu;
      etiket = 'YÃ¼ksek';
    }
    final oran = math.min(1.0, math.max(0.05, deger / (yuksek * 1.6)));
    final s = deger.toStringAsFixed(deger >= 10 ? 0 : 1).replaceAll(RegExp(r'\.0$'), '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(ad, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
              Text('$s g', style: TextStyle(fontSize: 13, color: cs.onSurface.o(0.7))),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: renk.o(0.15), borderRadius: BorderRadius.circular(10)),
                child: Text(etiket, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: renk)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(height: 8, color: cs.onSurface.o(0.08)),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: oran),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => FractionallySizedBox(
                    widthFactor: v,
                    child: Container(height: 8, color: renk),
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

class _MiniOzet extends StatelessWidget {
  final IconData ikon;
  final String ad;
  final String deger;
  final Color renk;
  const _MiniOzet({required this.ikon, required this.ad, required this.deger, required this.renk});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: renk.o(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: renk.o(0.35)),
      ),
      child: Column(
        children: [
          Icon(ikon, color: renk, size: 22),
          const SizedBox(height: 6),
          Text(ad, style: TextStyle(fontSize: 11.5, color: cs.onSurface.o(0.65))),
          const SizedBox(height: 2),
          Text(
            deger,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: renk),
          ),
        ],
      ),
    );
  }
}

class _BesinKutusu extends StatelessWidget {
  final String ad;
  final String deger;
  const _BesinKutusu({required this.ad, required this.deger});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Renk.ana.o(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(deger, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 2),
          Text(ad, style: TextStyle(fontSize: 12, color: cs.onSurface.o(0.65))),
        ],
      ),
    );
  }
}

class _Rozet extends StatelessWidget {
  final String metin;
  final Color renk;
  const _Rozet({required this.metin, required this.renk});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(color: renk, borderRadius: BorderRadius.circular(20)),
      child: Text(metin, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
    );
  }
}
