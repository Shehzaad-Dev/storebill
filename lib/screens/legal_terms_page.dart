import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/dukaan_theme.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Terms & Conditions',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heading('Terms & Conditions'),
                  _subheading('Last Updated: May 20, 2024'),
                  const SizedBox(height: 20),
                  _paragraph(
                    'Welcome to StoreBill. By downloading, installing, and using StoreBill, you agree to be bound by these Terms & Conditions.',
                  ),
                  _heading('1. License & Usage'),
                  _paragraph(
                    'StoreBill is licensed to you for personal, non-commercial use only. You may not:',
                  ),
                  _bulletPoint(
                    'Reverse engineer, decompile, or attempt to extract source code',
                  ),
                  _bulletPoint('Redistribute, sell, or lease StoreBill'),
                  _bulletPoint('Use StoreBill for illegal activities'),
                  _bulletPoint('Create derivative works based on StoreBill'),
                  _heading('2. User Content & Responsibility'),
                  _paragraph(
                    'You are responsible for all data you enter into StoreBill:',
                  ),
                  _bulletPoint(
                    'You guarantee that all business information is accurate and lawful',
                  ),
                  _bulletPoint(
                    'You will not use StoreBill for fraudulent or misleading invoices',
                  ),
                  _bulletPoint(
                    'You comply with all applicable tax laws and regulations',
                  ),
                  _bulletPoint(
                    'You will not use fake customer names or misleading details',
                  ),
                  _heading('3. Accuracy of Information'),
                  _paragraph(
                    'While StoreBill provides calculations and formatting tools, you are responsible for verifying all invoice amounts, taxes, and calculations before sharing or using them for business purposes.',
                  ),
                  _heading('4. Limitation of Liability'),
                  _paragraph(
                    'StoreBill is provided "AS IS" without warranties. We are not liable for:',
                  ),
                  _bulletPoint('Data loss or corruption'),
                  _bulletPoint('Device crashes or malfunctions'),
                  _bulletPoint(
                    'Calculation errors (though we aim for accuracy)',
                  ),
                  _bulletPoint('Indirect or consequential damages'),
                  _bulletPoint('Business losses or missed payments'),
                  _heading('5. No Warranty'),
                  _paragraph(
                    'StoreBill is provided without any express or implied warranty, including fitness for a particular purpose. We do not guarantee continuous, error-free service.',
                  ),
                  _heading('6. User Conduct'),
                  _paragraph('You agree not to:'),
                  _bulletPoint(
                    'Use StoreBill for any fraudulent, deceptive, or illegal purpose',
                  ),
                  _bulletPoint(
                    'Create invoices for goods/services not actually provided',
                  ),
                  _bulletPoint(
                    'Use StoreBill for money laundering or financial crimes',
                  ),
                  _bulletPoint(
                    'Harass or harm others using data from StoreBill',
                  ),
                  _bulletPoint(
                    'Attempt to gain unauthorized access to the app',
                  ),
                  _heading('7. Intellectual Property'),
                  _paragraph(
                    'StoreBill, its design, logos, and features are owned by the developers and protected by copyright laws. You may not use these for commercial purposes without permission.',
                  ),
                  _heading('8. Data Backup Responsibility'),
                  _paragraph(
                    'You are SOLELY responsible for backing up your data. StoreBill does not automatically backup your information. Loss of your device will result in loss of all data unless you manually exported backups.',
                  ),
                  _heading('9. Third-Party Links'),
                  _paragraph(
                    'StoreBill may contain links to third-party websites or services. We are not responsible for their content, privacy practices, or actions.',
                  ),
                  _heading('10. Advertisements'),
                  _paragraph(
                    'StoreBill does not display advertisements and does not integrate third-party ad networks at this time. If this changes, we will update these terms and the Privacy Policy.',
                  ),
                  _heading('11. Modifications'),
                  _paragraph(
                    'We reserve the right to modify, suspend, or discontinue StoreBill at any time without notice.',
                  ),
                  _heading('12. Termination'),
                  _paragraph(
                    'Your right to use StoreBill is terminated if you violate these terms. Upon termination, you must delete the app and all copies.',
                  ),
                  _heading('13. Governing Law'),
                  _paragraph(
                    'These Terms & Conditions are governed by applicable international law. Any disputes shall be resolved in accordance with local jurisdiction laws.',
                  ),
                  _heading('14. Dispute Resolution'),
                  _paragraph(
                    'Before pursuing legal action, you agree to attempt resolution through good faith negotiation and support contact.',
                  ),
                  _heading('15. Changes to Terms'),
                  _paragraph(
                    'We may update these Terms & Conditions. Continued use after updates constitutes acceptance of new terms.',
                  ),
                  _heading('16. Contact'),
                  _paragraph(
                    'For questions about these terms, contact: support@storebill.app',
                  ),
                  _heading('17. Entire Agreement'),
                  _paragraph(
                    'These Terms & Conditions constitute the entire agreement between you and StoreBill regarding your use of the application.',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _subheading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: GoogleFonts.dmSans(fontSize: 12, height: 1.6)),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
