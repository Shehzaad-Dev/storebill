import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../application/app_controller.dart';
import '../domain/app_models.dart';
import '../services/document_exporter.dart';
import '../theme/dukaan_theme.dart';
import '../utils/capture_share.dart';

class CardTab extends ConsumerStatefulWidget {
  const CardTab({super.key, this.onLeave});

  /// When opened from Settings / route, closes with this instead of switching main tab.
  final VoidCallback? onLeave;

  @override
  ConsumerState<CardTab> createState() => _CardTabState();
}

class _CardTabState extends ConsumerState<CardTab> {
  final GlobalKey _cardKey = GlobalKey();

  late final TextEditingController _biz;
  late final TextEditingController _role;
  late final TextEditingController _phone;
  late final TextEditingController _wa;
  late final TextEditingController _addr;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final s = ref.read(appControllerProvider);
    _biz = TextEditingController(text: s.shopName);
    _role = TextEditingController(text: s.businessRole);
    _phone = TextEditingController(text: s.shopPhone);
    _wa = TextEditingController(text: s.cardWhatsapp);
    _addr = TextEditingController(text: s.shopAddress);
    _email = TextEditingController(text: s.cardEmail);
  }

  @override
  void dispose() {
    _biz.dispose();
    _role.dispose();
    _phone.dispose();
    _wa.dispose();
    _addr.dispose();
    _email.dispose();
    super.dispose();
  }

  String _waData(String wa) {
    final d = wa.replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) return 'https://wa.me/';
    return 'https://wa.me/$d';
  }

  Future<void> _pickSolid(AppController ctrl, CardStyle cur) async {
    var c = cur.customColor;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Card color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: c,
            onColorChanged: (v) => c = v,
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ctrl.setCardStyle(cur.copyWith(mode: CardBackgroundMode.customSolid, customColor: c));
              Navigator.pop(ctx);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickGradient(AppController ctrl, CardStyle cur) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _GradientPickerDialog(
        initialA: cur.gradientA,
        initialB: cur.gradientB,
        onApply: (a, b) {
          ctrl.setCardStyle(
            cur.copyWith(
              mode: CardBackgroundMode.linearGradient,
              gradientA: a,
              gradientB: b,
              gradientBegin: Alignment.topLeft,
              gradientEnd: Alignment.bottomRight,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appControllerProvider);
    final ctrl = ref.read(appControllerProvider.notifier);
    final dec = s.cardStyle.buildDecoration();

    return Column(
      children: [
        _PageHeader(
          title: 'Business card',
          onBack: widget.onLeave ?? () => ctrl.setMainTab(0),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
            children: [
              RepaintBoundary(
                key: _cardKey,
                child: Container(
                  decoration: dec is BoxDecoration ? dec : BoxDecoration(color: DukaanColors.black, borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.all(20),
                  constraints: const BoxConstraints(minHeight: 180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.shopName, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: -0.3)),
                                const SizedBox(height: 3),
                                Text(s.businessRole.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white.withValues(alpha: 0.5), letterSpacing: 0.5)),
                              ],
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(9)),
                            alignment: Alignment.center,
                            child: Text(s.monogram, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          QrImageView(
                            data: _waData(s.cardWhatsapp),
                            version: QrVersions.auto,
                            size: 52,
                            backgroundColor: Colors.transparent,
                            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.white),
                            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _c(Icons.phone_rounded, s.shopPhone),
                      _c(Icons.place_outlined, s.shopAddress),
                      _c(Icons.chat_rounded, s.cardWhatsapp),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 9),
              _CardSection(
                title: 'CARD STYLE',
                icon: Icons.palette_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(onPressed: () => _pickSolid(ctrl, s.cardStyle), child: const Text('Solid color')),
                        OutlinedButton(onPressed: () => _pickGradient(ctrl, s.cardStyle), child: const Text('Custom gradient')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Templates', style: GoogleFonts.dmSans(fontSize: 11, color: DukaanColors.g4)),
                    const SizedBox(height: 6),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 7,
                      crossAxisSpacing: 7,
                      childAspectRatio: 1.35,
                      children: List.generate(CardStyle.templateColors.length, (i) {
                        final on = s.cardStyle.mode == CardBackgroundMode.templateSolid && s.cardStyle.templateIndex == i;
                        return GestureDetector(
                          onTap: () => ctrl.setCardStyle(
                            s.cardStyle.copyWith(mode: CardBackgroundMode.templateSolid, templateIndex: i),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: CardStyle.templateColors[i],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: on ? Colors.white : Colors.transparent, width: 2),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Stack(
                              children: [
                                if (on)
                                  const Positioned(
                                    top: 0,
                                    right: 0,
                                    child: CircleAvatar(radius: 8, backgroundColor: Colors.white, child: Icon(Icons.check, size: 10, color: Colors.black)),
                                  ),
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(CardStyle.templateNames[i], style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Text('Gradient presets', style: GoogleFonts.dmSans(fontSize: 11, color: DukaanColors.g4)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _gradChip(ctrl, s.cardStyle, const Color(0xFF0F172A), const Color(0xFF3B82F6), 'Ocean'),
                        _gradChip(ctrl, s.cardStyle, const Color(0xFF422006), const Color(0xFFF97316), 'Sunset'),
                        _gradChip(ctrl, s.cardStyle, const Color(0xFF14532D), const Color(0xFF4ADE80), 'Mint'),
                        _gradChip(ctrl, s.cardStyle, const Color(0xFF3B0764), const Color(0xFFA78BFA), 'Royal'),
                      ],
                    ),
                  ],
                ),
              ),
              _CardSection(
                title: 'CARD DETAILS',
                icon: Icons.storefront_rounded,
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Business name',
                      child: TextField(controller: _biz, onChanged: ctrl.setShopName, style: GoogleFonts.dmSans(fontSize: 13)),
                    ),
                    _LabeledField(
                      label: 'Your role / title',
                      child: TextField(controller: _role, onChanged: ctrl.setBusinessRole, style: GoogleFonts.dmSans(fontSize: 13)),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Phone',
                            child: TextField(controller: _phone, onChanged: ctrl.setShopPhone, keyboardType: TextInputType.phone, style: GoogleFonts.dmSans(fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _LabeledField(
                            label: 'WhatsApp',
                            child: TextField(controller: _wa, onChanged: ctrl.setCardWhatsapp, keyboardType: TextInputType.phone, style: GoogleFonts.dmSans(fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                    _LabeledField(
                      label: 'Address',
                      child: TextField(controller: _addr, onChanged: ctrl.setShopAddress, style: GoogleFonts.dmSans(fontSize: 13)),
                    ),
                    _LabeledField(
                      label: 'Email (optional)',
                      child: TextField(
                        controller: _email,
                        onChanged: ctrl.setCardEmail,
                        decoration: const InputDecoration(hintText: 'shop@email.com'),
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.dmSans(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: DukaanColors.black, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () async {
                        await shareWidgetPng(boundaryKey: _cardKey, filename: 'dukaan_card.png');
                      },
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text('Save image', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        side: const BorderSide(color: DukaanColors.g3),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final msg = '${s.shopName}\n${s.businessRole}\n${s.shopPhone}\n${s.shopAddress}\nWhatsApp: ${s.cardWhatsapp}';
                        await DocumentExporter.openWhatsAppWithPhone(s.cardWhatsapp, message: msg);
                        ctrl.bumpCardShareCount();
                      },
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: Text('Share', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _c(IconData i, String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(i, size: 12, color: Colors.white.withValues(alpha: 0.65)),
          const SizedBox(width: 6),
          Expanded(child: Text(t, style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white.withValues(alpha: 0.65)))),
        ],
      ),
    );
  }

  Widget _gradChip(AppController ctrl, CardStyle cur, Color a, Color b, String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        ctrl.setCardStyle(
          cur.copyWith(
            mode: CardBackgroundMode.linearGradient,
            gradientA: a,
            gradientB: b,
            gradientBegin: Alignment.topLeft,
            gradientEnd: Alignment.bottomRight,
          ),
        );
      },
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DukaanColors.black,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 14, 13),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                style: IconButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A), foregroundColor: Colors.white, minimumSize: const Size(40, 40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: DukaanColors.g4),
              const SizedBox(width: 6),
              Text(title, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 10, color: DukaanColors.g4, letterSpacing: 0.5)),
          const SizedBox(height: 3),
          child,
        ],
      ),
    );
  }
}

class _GradientPickerDialog extends StatefulWidget {
  const _GradientPickerDialog({
    required this.initialA,
    required this.initialB,
    required this.onApply,
  });

  final Color initialA;
  final Color initialB;
  final void Function(Color a, Color b) onApply;

  @override
  State<_GradientPickerDialog> createState() => _GradientPickerDialogState();
}

class _GradientPickerDialogState extends State<_GradientPickerDialog> {
  late Color _a;
  late Color _b;

  @override
  void initState() {
    super.initState();
    _a = widget.initialA;
    _b = widget.initialB;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom gradient'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Color A'),
            ColorPicker(pickerColor: _a, onColorChanged: (v) => setState(() => _a = v), enableAlpha: false),
            const Text('Color B'),
            ColorPicker(pickerColor: _b, onColorChanged: (v) => setState(() => _b = v), enableAlpha: false),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            widget.onApply(_a, _b);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
