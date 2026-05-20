import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../application/app_controller.dart';
import '../domain/app_state.dart';
import '../domain/khata_models.dart';
import '../services/document_exporter.dart';
import '../theme/dukaan_theme.dart';

class KhataTab extends ConsumerStatefulWidget {
  const KhataTab({super.key});

  @override
  ConsumerState<KhataTab> createState() => _KhataTabState();
}

class _KhataTabState extends ConsumerState<KhataTab> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<({KhataCustomer c, DateTime? act})> _sorted(AppState s) {
    final q = _query.trim().toLowerCase();
    var list = s.khataCustomers.map((c) => (c: c, act: s.lastActivityForCustomer(c.id))).toList();
    if (q.isNotEmpty) {
      list = list.where((e) {
        final c = e.c;
        return c.name.toLowerCase().contains(q) || c.phone.contains(q) || c.whatsapp.contains(q);
      }).toList();
    }
    list.sort((a, b) {
      final ta = a.act ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tb = b.act ?? DateTime.fromMillisecondsSinceEpoch(0);
      return tb.compareTo(ta);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appControllerProvider);
    final fmt = DocumentExporter.money(s);
    final rows = _sorted(s);
    final totalDue = s.totalKhataOutstanding;
    final countDue = s.khataCustomersWithDue;

    return Column(
      children: [
        Material(
          color: DukaanColors.black,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)),
                        child: const Icon(Icons.account_balance_wallet_outlined, color: DukaanColors.black, size: 17),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Khata', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                            Text('Customer ledger · offline', style: GoogleFonts.dmSans(fontSize: 9, color: Color(0xFF666666), letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/khata/add'),
                        style: IconButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A), foregroundColor: Colors.white),
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total pending', style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF999999))),
                              const SizedBox(height: 4),
                              Text(fmt.format(totalDue), style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Customers with due', style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF999999))),
                            const SizedBox(height: 4),
                            Text('$countDue', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v),
                    style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search name or phone',
                      hintStyle: GoogleFonts.dmSans(color: const Color(0xFF666666), fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF666666), size: 20),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _query.isEmpty ? 'No customers yet.\nTap + to add your first customer.' : 'No matches.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(fontSize: 13, color: DukaanColors.g4, height: 1.4),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final c = rows[i].c;
                    final due = s.customerDue(c.id);
                    final cleared = due < 0.01;
                    final act = rows[i].act;
                    final overdue = s.customerHasOverdueReminder(c.id);
                    return Material(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 0.5,
                      shadowColor: Colors.black12,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.push('/khata/customer/${c.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(color: DukaanColors.black, borderRadius: BorderRadius.circular(10)),
                                alignment: Alignment.center,
                                child: Text(
                                  c.name.trim().isEmpty ? '?' : c.name.trim().substring(0, 1).toUpperCase(),
                                  style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600))),
                                        if (overdue && !cleared)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(4)),
                                            child: Text('Overdue', style: GoogleFonts.dmSans(fontSize: 9, color: DukaanColors.red, fontWeight: FontWeight.w600)),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(c.phone.isEmpty ? '—' : c.phone, style: GoogleFonts.dmSans(fontSize: 11, color: DukaanColors.g5)),
                                    if (c.address.trim().isNotEmpty)
                                      Text(c.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.dmSans(fontSize: 10, color: DukaanColors.g4)),
                                    if (act != null)
                                      Text('Last activity · ${DateFormat('d MMM y').format(act)}', style: GoogleFonts.dmSans(fontSize: 9, color: DukaanColors.g4)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    cleared ? 'Cleared' : fmt.format(due),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: cleared ? const Color(0xFF15803D) : DukaanColors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: cleared ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      cleared ? 'Paid' : 'Due',
                                      style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: cleared ? const Color(0xFF15803D) : const Color(0xFF854D0E)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
