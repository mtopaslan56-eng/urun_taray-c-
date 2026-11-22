import 'package:flutter/material.dart';
import 'analiz.dart';

extension RenkEk on Color {
  /// withOpacity yerine: tÃ¼m Flutter sÃ¼rÃ¼mlerinde Ã§alÄ±ÅÄ±r.
  Color o(double opacity) => withAlpha((opacity * 255).round());
}

class Renk {
  static const Color ana = Color(0xFF00897B);
  static const Color anaKoyu = Color(0xFF00574F);
  static const Color iyi = Color(0xFF2E9E6B);
  static const Color orta = Color(0xFFF2A33A);
  static const Color kotu = Color(0xFFE5484D);
  static const Color notr = Color(0xFF8A97A0);
}

Color seviyeRengi(Seviye s) => switch (s) {
      Seviye.iyi => Renk.iyi,
      Seviye.orta => Renk.orta,
      Seviye.kotu => Renk.kotu,
      Seviye.bilinmiyor => Renk.notr,
    };

class Kart extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? renk;
  final Color? kenar;

  const Kart({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.renk,
    this.kenar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final koyu = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: renk ?? (koyu ? Color.alphaBlend(cs.primary.o(0.06), cs.surface) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kenar ?? (koyu ? cs.outlineVariant.o(0.5) : const Color(0xFFE1EBE9))),
        boxShadow: koyu
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0B3D37).o(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: child,
    );
  }
}

class BolumBasligi extends StatelessWidget {
  final String metin;
  const BolumBasligi(this.metin, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      metin,
      style: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  final double size;
  final bool acik; // true: beyaz zemin (koyu arka plan Ã¼zerinde)
  const AppLogo({super.key, this.size = 100, this.acik = false});

  @override
  Widget build(BuildContext context) {
    final ikonRenk = acik ? Renk.ana : Colors.white;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: acik ? Colors.white : null,
        gradient: acik
            ? null
            : const LinearGradient(
                colors: [Color(0xFF00897B), Color(0xFF26A69A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: (acik ? Colors.black : Renk.ana).o(acik ? 0.18 : 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: size * 0.6, color: ikonRenk),
          Positioned(
            bottom: size * 0.2,
            right: size * 0.2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
              child: Icon(Icons.eco, size: size * 0.15, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

/// UygulamanÄ±n aÃ§Ä±k/koyu temasÄ±nÄ± Ã¼retir.
ThemeData temaOlustur(Brightness b) {
  final koyu = b == Brightness.dark;
  final cs = ColorScheme.fromSeed(seedColor: Renk.ana, brightness: b);
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: koyu ? const Color(0xFF0E1514) : const Color(0xFFF3F8F7),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: cs.onSurface,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 70,
      elevation: 8,
      backgroundColor: koyu ? const Color(0xFF131C1B) : Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Renk.ana.o(koyu ? 0.35 : 0.16),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 12,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

/// SayfalarÄ±n Ã¼stÃ¼ndeki degrade baÅlÄ±k alanÄ±.
class HeroBaslik extends StatelessWidget {
  final String baslik;
  final String altBaslik;
  final Widget? ust;
  final Widget? alt;

  const HeroBaslik({super.key, required this.baslik, required this.altBaslik, this.ust, this.alt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 22, 24, 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Renk.anaKoyu, Renk.ana, Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(38)),
        boxShadow: [
          BoxShadow(color: Renk.anaKoyu.o(0.35), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ust != null) ...[ust!, const SizedBox(height: 18)],
          Text(
            baslik,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            altBaslik,
            style: TextStyle(fontSize: 15, height: 1.35, color: Colors.white.o(0.85)),
          ),
          if (alt != null) ...[const SizedBox(height: 20), alt!],
        ],
      ),
    );
  }
}

/// Degrade zeminli bÃ¼yÃ¼k eylem butonu.
class BuyukButon extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String altMetin;
  final VoidCallback onTap;
  final List<Color> renkler;

  const BuyukButon({
    super.key,
    required this.ikon,
    required this.baslik,
    required this.altMetin,
    required this.onTap,
    this.renkler = const [Renk.ana, Color(0xFF26A69A)],
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: renkler, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: renkler.first.o(0.35), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white.o(0.22), shape: BoxShape.circle),
                child: Icon(ikon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baslik,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(altMetin, style: TextStyle(color: Colors.white.o(0.85), fontSize: 13, height: 1.3)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ä°Ã§eriÄin sÄ±rayla yumuÅakÃ§a belirmesini saÄlar.
class GirisAnim extends StatefulWidget {
  final Widget child;
  final int sira;
  const GirisAnim({super.key, required this.child, this.sira = 0});

  @override
  State<GirisAnim> createState() => _GirisAnimState();
}

class _GirisAnimState extends State<GirisAnim> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _egri;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _egri = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    final bekle = 70 * (widget.sira > 8 ? 8 : widget.sira);
    Future.delayed(Duration(milliseconds: bekle), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _egri,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(_egri),
        child: widget.child,
      ),
    );
  }
}
