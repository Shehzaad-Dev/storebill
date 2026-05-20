import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/dukaan_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

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
                        'About StoreBill',
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
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: DukaanColors.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'StoreBill',
                            style: GoogleFonts.dmSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Invoice & Billing Made Simple',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: DukaanColors.g5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'v1.0.0',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              color: DukaanColors.g4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _heading('About StoreBill'),
                  _paragraph(
                    'StoreBill is a professional, offline-first invoicing and business management app designed for small business owners, shopkeepers, and entrepreneurs.',
                  ),
                  _paragraph(
                    'Whether you run a retail store, service business, or trading company, StoreBill helps you manage invoices, track customer payments, and maintain professional records—all without needing internet or a third-party service.',
                  ),
                  _heading('Key Features'),
                  _bulletPoint(
                    'Create professional invoices with your logo and branding',
                  ),
                  _bulletPoint('Generate receipts for quick cash transactions'),
                  _bulletPoint('Design and share business cards digitally'),
                  _bulletPoint(
                    'Track customer ledgers and payment history (Khata)',
                  ),
                  _bulletPoint(
                    'Set payment reminders for loan/credit transactions',
                  ),
                  _bulletPoint('Export data as PDF, CSV, and JSON backups'),
                  _bulletPoint('100% offline - no internet required'),
                  _bulletPoint('Dark mode support for comfortable viewing'),
                  _bulletPoint('Multi-currency support (PKR, USD, AED, SAR)'),
                  _heading('Why StoreBill?'),
                  _subheading('Completely Offline'),
                  _paragraph(
                    'All your data stays on your phone. No cloud sync, no external servers. You have complete control.',
                  ),
                  _subheading('Privacy-First'),
                  _paragraph(
                    'Your business information is yours alone. We never collect, transmit, or access your data.',
                  ),
                  _subheading('No Subscriptions'),
                  _paragraph(
                    'Free to use and ad-free. No hidden fees, no premium tiers required for basic functionality.',
                  ),
                  _subheading('Made for Small Business'),
                  _paragraph(
                    'Simple, intuitive design that doesn\'t require accounting knowledge. Perfect for traders, shops, and service providers.',
                  ),
                  _heading('Contact & Support'),
                  _paragraph(
                    'Have questions or feedback? We\'d love to hear from you!',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DukaanColors.g1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Support',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () =>
                              _launchURL('mailto:support@storebill.app'),
                          child: Text(
                            'support@storebill.app',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _heading('Important Notes'),
                  _paragraph(
                    'StoreBill is not an accounting software replacement. It is designed for record-keeping and invoice generation. You are responsible for complying with local tax laws and financial regulations.',
                  ),
                  _paragraph(
                    'We are not liable for any financial losses, missed payments, or incorrect calculations. Always verify invoice amounts before sending to customers.',
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
