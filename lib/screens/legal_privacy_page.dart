import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/dukaan_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
                        'Privacy Policy',
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
                  _heading('Privacy Policy'),
                  _subheading('Last Updated: May 20, 2024'),
                  const SizedBox(height: 20),
                  _paragraph(
                    'StoreBill is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information.',
                  ),
                  _heading('1. Data Storage'),
                  _paragraph(
                    'StoreBill stores ALL data locally on your device only. We do NOT collect, transmit, or store any of your business data on external servers, cloud databases, or our servers.',
                  ),
                  _subheading('What Data We Store Locally:'),
                  _bulletPoint('Invoice records and customer details'),
                  _bulletPoint('Payment history and ledger information'),
                  _bulletPoint('Business card templates and preferences'),
                  _bulletPoint('Application settings and preferences'),
                  _bulletPoint('Business information you manually enter'),
                  _heading('2. No Cloud Sync'),
                  _paragraph(
                    'StoreBill does NOT automatically sync, backup, or upload your data to any cloud service. Any backup or export is entirely under your control through manual export features.',
                  ),
                  _heading('3. Permissions'),
                  _paragraph('StoreBill may request permissions for:'),
                  _bulletPoint(
                    'Storage access - to save invoices, PDFs, and backups',
                  ),
                  _bulletPoint(
                    'Camera access - to capture business logo photos',
                  ),
                  _bulletPoint(
                    'Notification permission - to remind you about loan payments',
                  ),
                  _paragraph(
                    'All these permissions are used ONLY for functionality within the app and never for external data collection.',
                  ),
                  _heading('4. Monetization & Advertisements'),
                  _paragraph(
                    'StoreBill does not display advertisements and does not integrate any ad network SDKs. The app is currently ad-free.',
                  ),
                  _bulletPoint(
                    'No advertising identifiers or ad-related device data are collected by StoreBill.',
                  ),
                  _bulletPoint(
                    'Your business data is NEVER shared with third-party advertising networks.',
                  ),
                  _bulletPoint(
                    'If ads are added in a future release, this policy will be updated accordingly.',
                  ),
                  _heading('5. Device Safety'),
                  _paragraph(
                    'Your data is as safe as your phone. If your phone is lost or reset:',
                  ),
                  _bulletPoint(
                    'All app data is deleted unless you manually backed it up',
                  ),
                  _bulletPoint(
                    'You should regularly export backups to keep copies',
                  ),
                  _bulletPoint('We have NO way to recover lost data'),
                  _heading('6. No Third-Party Sharing'),
                  _paragraph(
                    'We do NOT sell, trade, or share your business information with any third parties.',
                  ),
                  _heading('7. Backup & Export'),
                  _paragraph(
                    'You control all backups. StoreBill allows you to:',
                  ),
                  _bulletPoint(
                    'Manually export backups as JSON files to your device storage',
                  ),
                  _bulletPoint(
                    'Manually export invoices and customers as CSV files',
                  ),
                  _bulletPoint(
                    'Share these files through any service you choose (email, cloud, etc.)',
                  ),
                  _paragraph(
                    'StoreBill NEVER automatically sends these files anywhere.',
                  ),
                  _heading('8. Updates & Changes'),
                  _paragraph(
                    'We may update this Privacy Policy from time to time. Changes will be effective immediately upon posting. Continued use of StoreBill constitutes acceptance of updated policies.',
                  ),
                  _heading('9. Contact Us'),
                  _paragraph(
                    'If you have privacy concerns or questions, please contact us through the app\'s support feature or email: support@storebill.app',
                  ),
                  _heading('10. Your Rights'),
                  _paragraph('You have the right to:'),
                  _bulletPoint('Access all your data stored on your device'),
                  _bulletPoint('Export your data at any time'),
                  _bulletPoint(
                    'Delete your data by uninstalling the app or using the clear data feature',
                  ),
                  _bulletPoint('Disable notifications and permissions'),
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
