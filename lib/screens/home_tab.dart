import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';
import '../application/app_controller.dart';
import '../services/document_exporter.dart';
import '../theme/dukaan_theme.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({
    super.key,
    required this.onTab,
    required this.onReceipt,
    required this.onHistory,
    required this.onKhata,
    required this.onBusinessCard,
  });

  final ValueChanged<int> onTab;
  final VoidCallback onReceipt;
  final VoidCallback onHistory;
  final VoidCallback onKhata;
  final VoidCallback onBusinessCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appControllerProvider);
    String compactMoney(double v) {
      final sym = s.currencySymbol;
      if (v >= 100000) return '$sym ${(v / 1000).toStringAsFixed(0)}k';
      if (v >= 1000) return '$sym ${(v / 1000).toStringAsFixed(1)}k';
      return DocumentExporter.money(s).format(v);
    }

    final now = DateTime.now();
    final day = DateFormat('EEEE').format(now).toLowerCase();
    final fmt = DocumentExporter.money(s);

    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final invWeek = s.invoiceHistory
        .where((e) => !e.updatedAt.isBefore(weekStart))
        .length;

    final recentEntries = <({DateTime t, Widget tile})>[];
    for (final i in s.invoiceHistory) {
      recentEntries.add((
        t: i.updatedAt,
        tile: _DocTile(
          icon: Icons.receipt_long_rounded,
          name: i.customerName.isEmpty
              ? 'Invoice #${i.number.toString().padLeft(3, '0')}'
              : i.customerName,
          meta:
              'Invoice #${i.number.toString().padLeft(3, '0')} · ${DateFormat('d MMM h:mm a').format(i.updatedAt)}',
          amount: fmt.format(i.grandTotal()),
          status: i.status == 'paid' ? _DocStatus.paid : _DocStatus.pending,
        ),
      ));
    }
    for (final r in s.receiptHistory) {
      recentEntries.add((
        t: r.updatedAt,
        tile: _DocTile(
          icon: Icons.sticky_note_2_outlined,
          name: 'Receipt #${r.number.toString().padLeft(3, '0')}',
          meta: 'Receipt · ${DateFormat('d MMM h:mm a').format(r.updatedAt)}',
          amount: fmt.format(r.total()),
          status: _DocStatus.none,
        ),
      ));
    }
    recentEntries.sort((a, b) => b.t.compareTo(a.t));
    final recentTiles = <Widget>[...recentEntries.take(6).map((e) => e.tile)];
    if (s.cardShareCount > 0 && recentTiles.length < 8) {
      recentTiles.add(
        _DocTile(
          icon: Icons.badge_outlined,
          name: 'Business card',
          meta: 'Last shared · ${DateFormat('d MMM').format(now)}',
          amount: 'Shared ${s.cardShareCount}×',
          amountIsGreen: true,
        ),
      );
    }

    return Column(
      children: [
        _TopBar(onBell: () => context.push('/notifications')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: DukaanColors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'today · $day',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        letterSpacing: 1.5,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                        children: const [
                          TextSpan(text: 'Your shop,\n'),
                          TextSpan(
                            text: 'fully paperless.',
                            style: TextStyle(color: Color(0xFFAAAAAA)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.45,
                      children: [
                        _QuickBtn(
                          icon: Icons.receipt_long_rounded,
                          title: 'New invoice',
                          subtitle: 'bill your customer',
                          onTap: () => onTab(1),
                        ),
                        _QuickBtn(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Khata',
                          subtitle: 'customer ledger',
                          onTap: onKhata,
                        ),
                        _QuickBtn(
                          icon: Icons.badge_outlined,
                          title: 'Business card',
                          subtitle: 'share your details',
                          onTap: onBusinessCard,
                        ),
                        _QuickBtn(
                          icon: Icons.sticky_note_2_outlined,
                          title: 'Quick receipt',
                          subtitle: 'fast cash memo',
                          onTap: onReceipt,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      value: '${s.invoiceCount}',
                      label: 'Invoices',
                      delta: Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 10,
                            color: DukaanColors.green,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$invWeek this week',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              color: DukaanColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatBox(
                      value: compactMoney(s.totalKhataOutstanding),
                      label: 'Khata due',
                      delta: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 10,
                            color: DukaanColors.red,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${s.khataCustomersWithDue} owing',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              color: DukaanColors.g5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _StatBox(
                value: compactMoney(s.totalBilledAllTime),
                label: 'Total billed',
                delta: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 10,
                      color: DukaanColors.green,
                    ),
                    const SizedBox(width: 3),
                    const Text(
                      'all time',
                      style: TextStyle(fontSize: 10, color: DukaanColors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT DOCUMENTS',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: DukaanColors.g4,
                      letterSpacing: 0.8,
                    ),
                  ),
                  InkWell(
                    onTap: onHistory,
                    child: Text(
                      'see all',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: DukaanColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (recentTiles.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Create an invoice or receipt to see it here.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: DukaanColors.g4,
                    ),
                  ),
                )
              else
                ...recentTiles,
            ],
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBell});

  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DukaanColors.black,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.request_quote_rounded,
                  color: DukaanColors.black,
                  size: 17,
                ),
              ),
              const SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'StoreBill',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'shopkeeper toolkit',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      color: const Color(0xFF666666),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: onBell,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF333333),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  const _QuickBtn({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
          ),
          padding: const EdgeInsets.fromLTRB(10, 13, 10, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: const Color(0xFFAAAAAA)),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.dmSans(
                  color: const Color(0xFF666666),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.delta,
  });

  final String value;
  final String label;
  final Widget delta;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? DukaanColors.darkSurface
            : DukaanColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DukaanColors.g3, width: 0.5),
      ),
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: DukaanColors.g4,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          delta,
        ],
      ),
    );
  }
}

enum _DocStatus { paid, pending, none }

class _DocTile extends StatelessWidget {
  const _DocTile({
    required this.icon,
    required this.name,
    required this.meta,
    required this.amount,
    this.status = _DocStatus.none,
    this.amountIsGreen = false,
  });

  final IconData icon;
  final String name;
  final String meta;
  final String amount;
  final _DocStatus status;
  final bool amountIsGreen;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).brightness == Brightness.dark
        ? DukaanColors.darkSurface
        : DukaanColors.white;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DukaanColors.g3, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: DukaanColors.black,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: DukaanColors.g4,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: GoogleFonts.dmSans(
                    fontSize: amountIsGreen ? 11 : 13,
                    fontWeight: FontWeight.w500,
                    color: amountIsGreen
                        ? DukaanColors.green
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (status == _DocStatus.paid)
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Paid',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        color: const Color(0xFF15803D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (status == _DocStatus.pending)
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF9C3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Pending',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        color: const Color(0xFF854D0E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
