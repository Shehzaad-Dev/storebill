import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../application/app_controller.dart';
import '../domain/app_models.dart';
import '../theme/dukaan_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _shop = TextEditingController();
  final _owner = TextEditingController();
  final _addr = TextEditingController();
  final _phone = TextEditingController();
  final _wa = TextEditingController();
  CurrencyCode _currency = CurrencyCode.pkr;
  File? _logoFile;
  bool _busy = false;

  @override
  void dispose() {
    _shop.dispose();
    _owner.dispose();
    _addr.dispose();
    _phone.dispose();
    _wa.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (x == null) return;
    setState(() => _logoFile = File(x.path));
  }

  Future<void> _save() async {
    if (_shop.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shop name and phone are required')));
      return;
    }
    setState(() => _busy = true);
    try {
      String? logoRel;
      if (_logoFile != null) {
        final bytes = await _logoFile!.readAsBytes();
        var ext = _logoFile!.path.split('.').last.toLowerCase();
        if (!['png', 'jpg', 'jpeg', 'webp'].contains(ext)) ext = 'png';
        if (ext == 'jpg') ext = 'jpeg';
        final repo = ref.read(appRepositoryProvider);
        logoRel = await repo.saveLogoBytes(bytes, ext: ext);
      }
      await ref.read(appControllerProvider.notifier).completeOnboarding(
            shopName: _shop.text.trim(),
            ownerName: _owner.text.trim(),
            shopAddress: _addr.text.trim(),
            shopPhone: _phone.text.trim(),
            shopWhatsapp: _wa.text.trim().isNotEmpty ? _wa.text.trim() : _phone.text.trim(),
            currency: _currency,
            logoRelativePath: logoRel,
          );
      if (!mounted) return;
      context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text('Welcome', style: GoogleFonts.dmSans(fontSize: 11, color: DukaanColors.g4, letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Text('Set up your business', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text(
              'Invoices, khata, and receipts will use this profile. Everything stays on your device.',
              style: GoogleFonts.dmSans(fontSize: 12, color: DukaanColors.g5, height: 1.35),
            ),
            const SizedBox(height: 22),
            _field('Shop name *', _shop),
            _field('Owner name', _owner),
            _field('Shop address', _addr, maxLines: 2),
            _field('Phone *', _phone, keyboard: TextInputType.phone),
            _field('WhatsApp', _wa, keyboard: TextInputType.phone, hint: 'Same as phone if empty'),
            const SizedBox(height: 8),
            Text('Currency', style: GoogleFonts.dmSans(fontSize: 10, color: DukaanColors.g4, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CurrencyCode.values
                  .map(
                    (c) => ChoiceChip(
                      label: Text('${c.symbol} ${c.label}', style: GoogleFonts.dmSans(fontSize: 11)),
                      selected: _currency == c,
                      onSelected: (_) => setState(() => _currency = c),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickLogo,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: Text(_logoFile == null ? 'Add logo (optional)' : 'Change logo', style: GoogleFonts.dmSans(fontSize: 12)),
            ),
            if (_logoFile != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_logoFile!, height: 72, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _busy ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: DukaanColors.black,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _busy
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Save & continue', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {TextInputType? keyboard, String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 10, color: DukaanColors.g4, letterSpacing: 0.5)),
          const SizedBox(height: 5),
          TextField(
            controller: c,
            maxLines: maxLines,
            keyboardType: keyboard,
            inputFormatters: keyboard == TextInputType.phone ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]'))] : null,
            decoration: InputDecoration(hintText: hint, filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            style: GoogleFonts.dmSans(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
