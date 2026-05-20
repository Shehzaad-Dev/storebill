import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/app_controller.dart';
import '../theme/dukaan_theme.dart';
import 'home_tab.dart';
import 'invoice_tab.dart';
import 'khata_tab.dart';
import 'settings_tab.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(appControllerProvider).mainTabIndex;
    final ctrl = ref.read(appControllerProvider.notifier);

    final pages = [
      HomeTab(
        onTab: ctrl.setMainTab,
        onReceipt: () => context.push('/receipt'),
        onHistory: () => context.push('/history'),
        onKhata: () => ctrl.setMainTab(2),
        onBusinessCard: () => context.push('/card'),
      ),
      const InvoiceTab(),
      const KhataTab(),
      const SettingsTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: nav, children: pages),
      bottomNavigationBar: _DukaanBottomNav(
        index: nav,
        onChanged: ctrl.setMainTab,
      ),
    );
  }
}

class _DukaanBottomNav extends StatelessWidget {
  const _DukaanBottomNav({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DukaanColors.black,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 14),
          child: Row(
            children: [
              _NavEntry(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: index == 0,
                onTap: () => onChanged(0),
              ),
              _NavEntry(
                icon: Icons.receipt_long_rounded,
                label: 'Invoice',
                selected: index == 1,
                onTap: () => onChanged(1),
              ),
              _NavEntry(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Khata',
                selected: index == 2,
                onTap: () => onChanged(2),
              ),
              _NavEntry(
                icon: Icons.settings_rounded,
                label: 'Settings',
                selected: index == 3,
                onTap: () => onChanged(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavEntry extends StatelessWidget {
  const _NavEntry({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = selected ? Colors.white : DukaanColors.navInactive;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: c),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 0.3,
                color: c,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
