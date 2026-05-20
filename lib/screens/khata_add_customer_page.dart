import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../application/app_controller.dart';
import '../domain/khata_models.dart';
import '../theme/dukaan_theme.dart';

class KhataAddCustomerPage extends ConsumerStatefulWidget {
  const KhataAddCustomerPage({super.key});

  @override
  ConsumerState<KhataAddCustomerPage> createState() => _KhataAddCustomerPageState();
}

class _KhataAddCustomerPageState extends ConsumerState<KhataAddCustomerPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _wa = TextEditingController();
  final _addr = TextEditingController();
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _wa.dispose();
    _addr.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer name is required')));
      return;
    }
    setState(() => _busy = true);
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final c = KhataCustomer(
        id: const Uuid().v4(),
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        whatsapp: _wa.text.trim(),
        address: _addr.text.trim(),
        note: _note.text.trim(),
        createdAtMs: now,
        updatedAtMs: now,
      );
      await ref.read(appControllerProvider.notifier).addKhataCustomer(c);
      if (!mounted) return;
      context.pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: DukaanColors.black,
        foregroundColor: Colors.white,
        title: Text('Add customer', style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tf('Name *', _name),
          _tf('Phone', _phone, phone: true),
          _tf('WhatsApp', _wa, phone: true),
          _tf('Address', _addr, maxLines: 2),
          _tf('Note', _note, maxLines: 2),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _save,
            style: FilledButton.styleFrom(backgroundColor: DukaanColors.black, minimumSize: const Size.fromHeight(46)),
            child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save customer'),
          ),
        ],
      ),
    );
  }

  Widget _tf(String label, TextEditingController c, {bool phone = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: phone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        style: GoogleFonts.dmSans(fontSize: 14),
      ),
    );
  }
}
