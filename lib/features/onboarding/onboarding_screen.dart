import 'package:flutter/material.dart';
import '../../core/storage/local_storage.dart';
import '../../app/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _ctrl = PageController();
  int _page = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.health_and_safety,
      'title': 'Mboka Care',
      'desc': 'Prenez soin de ce qui compte vraiment.\nGérez votre santé et celle de votre famille en toute sécurité.',
    },
    {
      'icon': Icons.qr_code_2,
      'title': 'QR Code d\'Urgence',
      'desc': 'Générez un QR Code contenant vos informations médicales essentielles pour les urgences.',
    },
    {
      'icon': Icons.alarm,
      'title': 'Rappels de Médicaments',
      'desc': 'Ne manquez jamais une prise de médicament grâce à nos rappels intelligents.',
    },
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _finish() async {
    await LocalStorage.setOnboardingComplete();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.roleSelector);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        i == 0
                          ? Image.asset('assets/images/logo.png', width: 140, height: 140)
                          : Container(
                              width: 120, height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(p['icon'] as IconData, size: 60, color: Colors.white),
                            ),
                        const SizedBox(height: 40),
                        Text(p['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(p['desc'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 24 : 8, height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? const Color(0xFF2196F3) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Passer', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: _page < _pages.length - 1
                      ? () => _ctrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease)
                      : _finish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _page < _pages.length - 1 ? 'Suivant' : 'Démarrer',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
