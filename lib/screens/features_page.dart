import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/dukaan_theme.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  static const _items = <_Feat>[
    _Feat(Icons.receipt_long_rounded, 'Professional invoice', 'Shop name, logo, items, tax, discount, footer note. Saves as PDF.'),
    _Feat(Icons.sticky_note_2_outlined, 'Quick receipt / cash memo', 'Thermal-style receipt for fast cash sales. Print or WhatsApp.'),
    _Feat(Icons.badge_outlined, 'Business card maker', '6 premium dark templates. Save as image and share anywhere.'),
    _Feat(Icons.chat_rounded, 'WhatsApp sharing', 'Send invoice or card directly to any WhatsApp number.'),
    _Feat(Icons.history_rounded, 'Invoice history', 'All past invoices saved on phone. Search, reopen, resend.'),
    _Feat(Icons.bar_chart_rounded, 'Monthly sales summary', 'See total billed, number of invoices, top customers.'),
    _Feat(Icons.verified_user_outlined, 'Customer book (Khata)', 'Save customers, track who owes money (udhar). No login.'),
    _Feat(Icons.qr_code_2_rounded, 'QR code on card', 'Auto QR code on business card links to WhatsApp or phone.'),
    _Feat(Icons.currency_rupee_rounded, 'Multi-currency', 'Rs, \$, AED, SAR — works for Pakistan, UAE, Saudi sellers.'),
    _Feat(Icons.storage_rounded, 'Full offline + backup', 'Works with zero internet. Export all data to your phone storage.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Material(
            color: DukaanColors.black,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 14, 13),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(40, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                    const SizedBox(width: 6),
                    Text('All features', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              itemCount: _items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final f = _items[i];
                return Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF333333) : DukaanColors.g3, width: 0.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(color: DukaanColors.black, borderRadius: BorderRadius.circular(8)),
                        child: Icon(f.icon, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.title, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(f.desc, style: GoogleFonts.dmSans(fontSize: 11, color: DukaanColors.g4, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Feat {
  const _Feat(this.icon, this.title, this.desc);
  final IconData icon;
  final String title;
  final String desc;
}
