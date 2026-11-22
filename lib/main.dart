import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alerji.dart';
import 'barkod_sekmesi.dart';
import 'etiket_sekmesi.dart';
import 'gecmis_ayarlar.dart';
import 'oneri_carki.dart';
import 'ui_ortak.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlerjiDeposu.yukle();
  runApp(const UrunTarayiciApp());
}

class UrunTarayiciApp extends StatefulWidget {
  const UrunTarayiciApp({super.key});

  @override
  State<UrunTarayiciApp> createState() => _UrunTarayiciAppState();
}

class _UrunTarayiciAppState extends State<UrunTarayiciApp> {
  bool _koyu = false;

  @override
  void initState() {
    super.initState();
    _oku();
  }

  Future<void> _oku() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _koyu = p.getBool('koyu_mod') ?? false);
  }

  Future<void> _degistir(bool v) async {
    setState(() => _koyu = v);
    final p = await SharedPreferences.getInstance();
    await p.setBool('koyu_mod', v);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sağlık Tarayıcı',
      debugShowCheckedModeBanner: false,
      theme: temaOlustur(Brightness.light),
      darkTheme: temaOlustur(Brightness.dark),
      themeMode: _koyu ? ThemeMode.dark : ThemeMode.light,
      home: AnaIskelet(koyuMod: _koyu, onKoyuDegisti: _degistir),
    );
  }
}

class AnaIskelet extends StatefulWidget {
  final bool koyuMod;
  final ValueChanged<bool> onKoyuDegisti;

  const AnaIskelet({super.key, required this.koyuMod, required this.onKoyuDegisti});

  @override
  State<AnaIskelet> createState() => _AnaIskeletState();
}

class _AnaIskeletState extends State<AnaIskelet> {
  int _sekme = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _sekme,
        children: [
          const BarkodSekmesi(),
          const EtiketSekmesi(),
          const OneriCarki(),
          const GecmisSekmesi(),
          AyarlarSekmesi(koyuMod: widget.koyuMod, onDegisti: widget.onKoyuDegisti),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _sekme,
        onDestinationSelected: (i) => setState(() => _sekme = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_rounded),
            selectedIcon: Icon(Icons.qr_code_scanner_rounded, color: Renk.ana),
            label: 'Barkod',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner_rounded, color: Renk.ana),
            label: 'Etiket',
          ),
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            selectedIcon: Icon(Icons.casino_rounded, color: Renk.ana),
            label: 'Çark',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_rounded, color: Renk.ana),
            label: 'Geçmiş',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded, color: Renk.ana),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}
