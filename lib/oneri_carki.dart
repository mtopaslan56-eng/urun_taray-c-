import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'alerji.dart';
import 'ui_ortak.dart';

class CarkOgesi {
  final IconData ikon;
  final String ad;
  final String neden;
  final Set<String> alerjenler; // alerji.dart'taki alerjen kimlikleri
  const CarkOgesi(this.ikon, this.ad, this.neden, [this.alerjenler = const <String>{}]);
}

class _Hedef {
  final IconData ikon;
  final List<CarkOgesi> ogeler;
  const _Hedef(this.ikon, this.ogeler);
}

const Map<String, _Hedef> _hedefler = {
  'Sporcu': _Hedef(Icons.fitness_center_rounded, [
    CarkOgesi(Icons.bolt_rounded, 'Muz + fÄ±stÄ±k ezmesi',
        'HÄ±zlÄ± karbonhidrat ve saÄlÄ±klÄ± yaÄ; antrenman Ã¶ncesi iÃ§in pratik bir enerji kaynaÄÄ±.', {'fistik'}),
    CarkOgesi(Icons.egg_alt_rounded, 'HaÅlanmÄ±Å yumurta',
        'Kaliteli protein kaynaÄÄ±; antrenman sonrasÄ± kas onarÄ±mÄ±nÄ± destekler.', {'yumurta'}),
    CarkOgesi(Icons.local_drink_rounded, 'SÃ¼zme yoÄurt',
        'YÃ¼ksek protein ve probiyotik iÃ§erir; tok tutar ve sindirimi destekler.', {'sut'}),
    CarkOgesi(Icons.park_rounded, 'ÃiÄ badem ve ceviz',
        'DoymamÄ±Å yaÄ, protein ve lif saÄlar; bir avuÃ§ yeterlidir.', {'kuruyemis'}),
    CarkOgesi(Icons.restaurant_rounded, 'FÄ±rÄ±nda tatlÄ± patates',
        'YavaÅ sindirilen karbonhidrat; uzun antrenmanlar Ã¶ncesinde uzun sÃ¼reli enerji verir.'),
    CarkOgesi(Icons.breakfast_dining_rounded, 'Yulaf + yoÄurt',
        'Lif ve kompleks karbonhidrat; sabah antrenmanÄ± Ã¶ncesi iÃ§in gÃ¼zel bir seÃ§im.', {'gluten', 'sut'}),
    CarkOgesi(Icons.set_meal_rounded, 'Izgara tavuk / ton balÄ±ÄÄ±',
        'DÃ¼ÅÃ¼k yaÄlÄ±, yÃ¼ksek protein; ana Ã¶ÄÃ¼nde kas geliÅimini destekler.', {'balik'}),
    CarkOgesi(Icons.dinner_dining_rounded, 'Lor peyniri',
        'YavaÅ sindirilen kazein proteini iÃ§erir; akÅam atÄ±ÅtÄ±rmasÄ± iÃ§in uygundur.', {'sut'}),
  ]),
  'Kilo vermek': _Hedef(Icons.monitor_weight_outlined, [
    CarkOgesi(Icons.grass_rounded, 'SalatalÄ±k ve havuÃ§',
        'Ãok dÃ¼ÅÃ¼k kalorili ve sulu; kemirme isteÄini az kalori ile karÅÄ±lar.'),
    CarkOgesi(Icons.eco_rounded, 'Elma + tarÃ§Ä±n',
        'Lif iÃ§erir ve tatlÄ± isteÄini bastÄ±rÄ±r; yavaÅ yenirse tokluk hissi uzar.'),
    CarkOgesi(Icons.local_drink_rounded, 'Sade yoÄurt',
        'Protein iÃ§erir, Åekersizdir; meyveyle ya da tarÃ§Ä±nla tatlandÄ±rÄ±labilir.', {'sut'}),
    CarkOgesi(Icons.egg_alt_rounded, 'HaÅlanmÄ±Å yumurta',
        'Az kalori iÃ§in yÃ¼ksek tokluk saÄlar.', {'yumurta'}),
    CarkOgesi(Icons.rice_bowl_rounded, 'Nohutlu yeÅil salata',
        'Bitkisel protein ve lif; ana Ã¶ÄÃ¼n olarak da yenebilir.'),
    CarkOgesi(Icons.emoji_food_beverage_rounded, 'Åekersiz bitki Ã§ayÄ±',
        'Kalorisizdir; ara Ã¶ÄÃ¼n isteÄini geciktirmeye yardÄ±mcÄ± olur.'),
    CarkOgesi(Icons.local_florist_rounded, 'Ãilek / bÃ¶ÄÃ¼rtlen',
        'Meyveler arasÄ±nda Åekeri dÃ¼ÅÃ¼k, lifi yÃ¼ksektir.'),
    CarkOgesi(Icons.soup_kitchen_rounded, 'Sebze Ã§orbasÄ±',
        'Hacimli ve dÃ¼ÅÃ¼k kalorili; Ã¶ÄÃ¼n Ã¶ncesi iÃ§mek porsiyonu kÃ¼Ã§Ã¼ltebilir.', {'kereviz'}),
  ]),
  'Genel saÄlÄ±k': _Hedef(Icons.favorite_rounded, [
    CarkOgesi(Icons.local_florist_rounded, 'Mevsim meyvesi',
        'Vitamin ve lif kaynaÄÄ±dÄ±r; paketli tatlÄ± yerine iyi bir alternatiftir.'),
    CarkOgesi(Icons.park_rounded, 'Bir avuÃ§ kuruyemiÅ',
        'Kalp saÄlÄ±ÄÄ±nÄ± destekleyen doymamÄ±Å yaÄlar iÃ§erir.', {'kuruyemis', 'fistik'}),
    CarkOgesi(Icons.grass_rounded, 'ZeytinyaÄlÄ± sebze',
        'Lif ve antioksidan aÃ§Ä±sÄ±ndan zengindir.'),
    CarkOgesi(Icons.set_meal_rounded, 'FÄ±rÄ±nda balÄ±k',
        'Omega-3 yaÄ asitleri saÄlar; haftada 2 kez Ã¶nerilir.', {'balik'}),
    CarkOgesi(Icons.local_drink_rounded, 'Kefir',
        'Probiyotik iÃ§erir; baÄÄ±rsak florasÄ±nÄ± destekleyebilir.', {'sut'}),
    CarkOgesi(Icons.soup_kitchen_rounded, 'Mercimek Ã§orbasÄ±',
        'Bitkisel protein, lif ve demir iÃ§erir.'),
    CarkOgesi(Icons.bakery_dining_rounded, 'Tam tahÄ±l ekmek + peynir',
        'Rafine ekmeÄe gÃ¶re daha uzun tok tutar.', {'gluten', 'sut'}),
    CarkOgesi(Icons.lunch_dining_rounded, 'Avokadolu tost',
        'SaÄlÄ±klÄ± yaÄ ve lif iÃ§erir; porsiyonu Ã¶lÃ§Ã¼lÃ¼ tutun.', {'gluten'}),
  ]),
  'Market Ã¼rÃ¼nleri': _Hedef(Icons.shopping_basket_rounded, [
    CarkOgesi(Icons.local_drink_rounded, 'SÃ¼taÅ Kefir',
        'Probiyotik iÃ§erir, baÄÄ±rsak florasÄ±nÄ± dÃ¼zenlemeye yardÄ±mcÄ± olur.', {'sut'}),
    CarkOgesi(Icons.breakfast_dining_rounded, 'Eti Form BiskÃ¼vi',
        'Tam buÄday unu iÃ§eren bir biskÃ¼vidir; lif kaynaÄÄ± olarak atÄ±ÅtÄ±rmalÄ±klara gÃ¶re daha iyi bir seÃ§imdir.', {'gluten'}),
    CarkOgesi(Icons.bakery_dining_rounded, 'Torku Tam BuÄday',
        'Tam buÄday Ã¼rÃ¼nleri rafine unlu Ã¼rÃ¼nlere gÃ¶re daha uzun sÃ¼re tok tutar.', {'gluten'}),
    CarkOgesi(Icons.water_drop_rounded, 'Åeker ilavesiz meyve suyu',
        'Etiketinde "Åeker ilavesiz" yazanlarÄ± seÃ§in. Meyve Åekeri iÃ§erdiÄi iÃ§in yine de Ã¶lÃ§Ã¼lÃ¼ tÃ¼ketin.'),
    CarkOgesi(Icons.local_drink_rounded, 'PÄ±nar SÃ¼t',
        'Kalsiyum ve D vitamini kaynaÄÄ±dÄ±r.', {'sut'}),
    CarkOgesi(Icons.park_rounded, 'TadÄ±m Badem',
        'E vitamini ve saÄlÄ±klÄ± yaÄlar aÃ§Ä±sÄ±ndan zengindir; bir avuÃ§ yeterlidir.', {'kuruyemis'}),
    CarkOgesi(Icons.emoji_food_beverage_rounded, 'DoÄadan YeÅil Ãay',
        'Antioksidan iÃ§erir; Åekersiz iÃ§ilmelidir.'),
    CarkOgesi(Icons.local_drink_rounded, 'Sek Kefir',
        'Probiyotik iÃ§erir, baÄÄ±rsak saÄlÄ±ÄÄ±nÄ± destekler.', {'sut'}),
  ]),
};

const List<Color> _dilimRenkleri = [
  Color(0xFF00897B),
  Color(0xFF2E9E6B),
  Color(0xFF26A69A),
  Color(0xFF00796B),
  Color(0xFF43A047),
  Color(0xFF4DB6AC),
  Color(0xFF00695C),
  Color(0xFF66BB6A),
];

class OneriCarki extends StatefulWidget {
  const OneriCarki({super.key});

  @override
  State<OneriCarki> createState() => _OneriCarkiState();
}

class _OneriCarkiState extends State<OneriCarki> with SingleTickerProviderStateMixin {
  static const double _iki = 2 * math.pi;

  late final AnimationController _kontrol;
  final math.Random _rnd = math.Random();

  String _hedef = 'Sporcu';
  double _aci = 0; // DuraÄan haldeki dÃ¶nÃ¼Å aÃ§Ä±sÄ± (radyan)
  Animation<double>? _anim;
  bool _donuyor = false;
  CarkOgesi? _seciliOge;
  int _sonTik = -1;

  /// Alerji profilindeki maddeleri iÃ§eren Ã¶neriler Ã§arktan Ã§Ä±karÄ±lÄ±r.
  List<CarkOgesi> _liste(Set<String> alerji) => [
        for (final o in _hedefler[_hedef]!.ogeler)
          if (!o.alerjenler.any(alerji.contains)) o,
      ];

  double get _gosterilenAci => (_donuyor && _anim != null) ? _anim!.value : _aci;

  @override
  void initState() {
    super.initState();
    _kontrol = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200));
    _kontrol.addListener(() {
      if (!_donuyor || _anim == null) return;
      final n = _liste(AlerjiDeposu.secili.value).length;
      if (n == 0) return;
      final i = _indeks(_anim!.value, n);
      if (i != _sonTik) {
        _sonTik = i;
        HapticFeedback.selectionClick();
      }
    });
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  /// Ãstteki ok hangi dilimin Ã¼zerinde? (Ãark dÃ¶ndÃ¼kÃ§e ok sabit kalÄ±r.)
  int _indeks(double aci, int n) {
    final dilim = _iki / n;
    var x = (-aci) % _iki;
    if (x < 0) x += _iki;
    return (x / dilim).floor() % n;
  }

  void _hedefSec(String h) {
    if (_donuyor || h == _hedef) return;
    setState(() {
      _hedef = h;
      _seciliOge = null;
    });
  }

  void _cevir(List<CarkOgesi> liste) {
    if (_donuyor || liste.length < 2) return;
    final n = liste.length;
    final dilim = _iki / n;
    final hedefDilim = _rnd.nextInt(n);
    final oran = 0.15 + _rnd.nextDouble() * 0.7;
    final hedefKonum = (hedefDilim + oran) * dilim;

    var fark = (-hedefKonum - _aci) % _iki;
    if (fark < 0) fark += _iki;
    final tur = 5 + _rnd.nextInt(3);
    final bitis = _aci + tur * _iki + fark;

    _anim = Tween<double>(begin: _aci, end: bitis).animate(
      CurvedAnimation(parent: _kontrol, curve: Curves.easeOutQuart),
    );
    _sonTik = -1;
    HapticFeedback.mediumImpact();
    setState(() {
      _donuyor = true;
      _seciliOge = null;
    });

    _kontrol.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      var son = bitis % _iki;
      if (son < 0) son += _iki;
      setState(() {
        _aci = son;
        _donuyor = false;
        _seciliOge = liste[_indeks(son, n)];
      });
      HapticFeedback.heavyImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ãneri ÃarkÄ±')),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: AlerjiDeposu.secili,
        builder: (context, alerji, _) {
          final liste = _liste(alerji);
          // Profil deÄiÅip seÃ§ili Ã¶neri listeden dÃ¼ÅtÃ¼yse sonucu temizle.
          final secili = (_seciliOge != null && liste.contains(_seciliOge)) ? _seciliOge : null;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            children: [
              Text(
                'Hedefini seÃ§, Ã§arkÄ± Ã§evir; sana uygun bir Ã¶neri Ã§Ä±ksÄ±n.',
                style: TextStyle(fontSize: 14.5, height: 1.4, color: cs.onSurface.o(0.65)),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  for (final e in _hedefler.entries)
                    ChoiceChip(
                      avatar: Icon(e.value.ikon, size: 18, color: e.key == _hedef ? Colors.white : Renk.ana),
                      label: Text(e.key),
                      selected: e.key == _hedef,
                      showCheckmark: false,
                      selectedColor: Renk.ana,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: e.key == _hedef ? Colors.white : cs.onSurface,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (_) => _hedefSec(e.key),
                    ),
                ],
              ),
              if (alerji.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Renk.kotu.o(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Renk.kotu.o(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.health_and_safety_rounded, color: Renk.kotu, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Alerji profilinize gÃ¶re uygun olmayan Ã¶neriler Ã§arktan Ã§Ä±karÄ±ldÄ±. '
                          'Bu eleme genel bilgiye dayanÄ±r; Ã¼rÃ¼n etiketini yine de kontrol edin.',
                          style: TextStyle(fontSize: 12.5, height: 1.35, color: cs.onSurface.o(0.8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (liste.length < 3)
                Kart(
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: cs.onSurface.o(0.5)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Alerji profilinize uygun yeterli Ã¶neri kalmadÄ±. BaÅka bir hedef seÃ§meyi deneyin.'),
                      ),
                    ],
                  ),
                )
              else
                Center(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final kenar = math.min(c.maxWidth, 340.0);
                      return SizedBox(width: kenar, height: kenar, child: _cark(liste));
                    },
                  ),
                ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _sonucKarti(context, secili, liste.length >= 3),
              ),
              const SizedBox(height: 22),
              const BolumBasligi('Ãarktaki seÃ§enekler'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final o in liste)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Renk.ana.o(0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(o.ikon, size: 16, color: Renk.ana),
                          const SizedBox(width: 6),
                          Text(o.ad, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _cark(List<CarkOgesi> liste) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // DÄ±Å halka ve gÃ¶lge
        Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Renk.anaKoyu, Color(0xFF00897B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(color: Renk.anaKoyu.o(0.4), blurRadius: 28, offset: const Offset(0, 14))],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: AnimatedBuilder(
            animation: _kontrol,
            builder: (context, _) => Transform.rotate(
              angle: _gosterilenAci,
              child: CustomPaint(
                size: Size.infinite,
                painter: _CarkCizici(liste),
              ),
            ),
          ),
        ),
        CustomPaint(size: Size.infinite, painter: const _KenarIsiklari()),
        // Orta dÃ¼Äme
        GestureDetector(
          onTap: () => _cevir(liste),
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFE0F2F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Renk.anaKoyu, width: 4),
              boxShadow: [BoxShadow(color: Colors.black.o(0.28), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            alignment: Alignment.center,
            child: _donuyor
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3, color: Renk.anaKoyu),
                  )
                : const Text(
                    'ÃEVÄ°R',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Renk.anaKoyu),
                  ),
          ),
        ),
        // Ãstteki ok
        const Positioned(top: 0, child: CustomPaint(size: Size(30, 38), painter: _OkCizici())),
      ],
    );
  }

  Widget _sonucKarti(BuildContext context, CarkOgesi? o, bool carkVar) {
    final cs = Theme.of(context).colorScheme;
    if (o == null) {
      return Kart(
        key: const ValueKey('bos'),
        child: Row(
          children: [
            const Icon(Icons.touch_app_rounded, color: Renk.ana, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                !carkVar
                    ? 'Ãark iÃ§in yeterli Ã¶neri yok.'
                    : (_donuyor ? 'Ãark dÃ¶nÃ¼yorâ¦' : 'Ortadaki dÃ¼Ämeye dokunarak Ã§arkÄ± Ã§evirin.'),
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: cs.onSurface.o(0.8)),
              ),
            ),
          ],
        ),
      );
    }
    return Kart(
      key: ValueKey('sonuc-${o.ad}-$_hedef'),
      kenar: Renk.ana.o(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Renk.ana, Color(0xFF26A69A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(o.ikon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ãnerimiz Â· $_hedef',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Renk.ana),
                    ),
                    const SizedBox(height: 3),
                    Text(o.ad, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(o.neden, style: TextStyle(fontSize: 14, height: 1.45, color: cs.onSurface.o(0.8))),
          if (_hedef == 'Market Ã¼rÃ¼nleri') ...[
            const SizedBox(height: 12),
            const Text(
              'ÃrÃ¼n iÃ§erikleri zamanla deÄiÅebilir; satÄ±n almadan Ã¶nce barkodunu ya da etiketini uygulamada taratÄ±p kontrol edin.',
              style: TextStyle(fontSize: 12.5, height: 1.4, fontWeight: FontWeight.w600, color: Renk.ana),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'Ãneriler genel bilgilendirme amaÃ§lÄ±dÄ±r; alerjiniz ya da saÄlÄ±k sorununuz varsa uzmanÄ±nÄ±za danÄ±ÅÄ±n.',
            style: TextStyle(fontSize: 11.5, height: 1.35, color: cs.onSurface.o(0.5)),
          ),
        ],
      ),
    );
  }
}

class _CarkCizici extends CustomPainter {
  final List<CarkOgesi> ogeler;
  const _CarkCizici(this.ogeler);

  @override
  void paint(Canvas canvas, Size size) {
    final merkez = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: merkez, radius: r);
    final n = ogeler.length;
    final dilim = 2 * math.pi / n;

    final cizgi = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (var i = 0; i < n; i++) {
      final baslangic = -math.pi / 2 + i * dilim;
      final renk = _dilimRenkleri[i % _dilimRenkleri.length];
      canvas.drawArc(rect, baslangic, dilim, true, Paint()..color = renk);
      canvas.drawArc(rect, baslangic, dilim, true, cizgi);

      final orta = baslangic + dilim / 2;
      final konum = merkez + Offset(math.cos(orta), math.sin(orta)) * (r * 0.66);

      // Beyaz yuvarlak iÃ§inde dilim renginde ikon
      canvas.drawCircle(konum, r * 0.17, Paint()..color = Colors.white);
      final ikon = ogeler[i].ikon;
      final tp = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(ikon.codePoint),
          style: TextStyle(
            fontSize: r * 0.2,
            fontFamily: ikon.fontFamily,
            package: ikon.fontPackage,
            color: renk,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(konum.dx, konum.dy);
      canvas.rotate(orta + math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    canvas.drawCircle(
      merkez,
      r,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant _CarkCizici eski) => eski.ogeler != ogeler;
}

/// ÃarkÄ±n dÄ±Å halkasÄ±ndaki dekoratif Ä±ÅÄ±k noktalarÄ±.
class _KenarIsiklari extends CustomPainter {
  const _KenarIsiklari();

  @override
  void paint(Canvas canvas, Size size) {
    final merkez = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 7;
    const adet = 24;
    for (var i = 0; i < adet; i++) {
      final a = 2 * math.pi * i / adet;
      canvas.drawCircle(
        merkez + Offset(math.cos(a), math.sin(a)) * r,
        2.6,
        Paint()..color = i.isEven ? Colors.white : const Color(0xFFFFD54F),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OkCizici extends CustomPainter {
  const _OkCizici();

  @override
  void paint(Canvas canvas, Size size) {
    final yol = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawShadow(yol, Colors.black, 4, true);
    canvas.drawPath(yol, Paint()..color = Renk.kotu);
    canvas.drawPath(
      yol,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
