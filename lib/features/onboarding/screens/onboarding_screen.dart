import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../../../core/theme.dart";
import "../../../main.dart";

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingPage({required this.icon, required this.title, required this.description});
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(icon: Icons.folder_special_outlined, title: "Centralisez tout", description: "Documents, recus, garanties, billets et notes, tous au meme endroit."),
    _OnboardingPage(icon: Icons.notifications_active_outlined, title: "Ne ratez plus une echeance", description: "Des rappels automatiques avant l expiration de vos documents importants."),
    _OnboardingPage(icon: Icons.shield_outlined, title: "Vos donnees, protegees", description: "Chiffrement, acces prive et securite au coeur de LifeVault."),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_onboarding", true);
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthGate()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextButton(onPressed: _finish, child: const Text("Passer")),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() { _currentPage = i; }),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(gradient: AppColors.gradientPrimary.scale(0.15), borderRadius: BorderRadius.circular(AppRadius.lg)),
                          child: Icon(page.icon, size: 56, color: AppColors.primaryLight),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(page.title, style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.md),
                        Text(page.description, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(color: _currentPage == i ? AppColors.primary : AppColors.borderDark, borderRadius: BorderRadius.circular(AppRadius.pill)),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ElevatedButton(
                onPressed: _currentPage == _pages.length - 1
                    ? _finish
                    : () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                child: Text(_currentPage == _pages.length - 1 ? "Commencer" : "Suivant"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}