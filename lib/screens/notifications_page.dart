import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/app_controller.dart';
import '../theme/dukaan_theme.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appControllerProvider);
    final ctrl = ref.read(appControllerProvider.notifier);
    final now = DateTime.now();
    final reminders =
        s.invoiceHistory
            .where((e) => e.isKhata && e.reminderAt != null)
            .toList()
          ..sort((a, b) => a.reminderAt!.compareTo(b.reminderAt!));

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: reminders.isEmpty
          ? const Center(child: Text('No reminders'))
          : ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (ctx, i) {
                final inv = reminders[i];
                final due = inv.reminderAt!;
                final overdue = due.isBefore(now);
                return ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: overdue ? DukaanColors.red : DukaanColors.black,
                  ),
                  title: Text(
                    inv.customerName.isEmpty
                        ? 'Invoice #${inv.number}'
                        : inv.customerName,
                  ),
                  subtitle: Text(
                    '${inv.grandTotal().toStringAsFixed(0)} · ${due.toLocal()}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'open') {
                        await ctrl.loadInvoiceIntoDraft(inv);
                        if (context.mounted) context.go('/');
                        ctrl.setMainTab(1);
                      } else if (v == 'collected') {
                        if (inv.khataCustomerId != null &&
                            inv.khataCustomerId!.isNotEmpty) {
                          await ctrl.receivePayment(
                            customerId: inv.khataCustomerId!,
                            amount: inv.grandTotal(),
                            method: 'cash',
                            note: 'Collected via notifications',
                            paidAt: DateTime.now(),
                          );
                          await ctrl.deleteInvoice(inv.id);
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'open', child: Text('Open')),
                      const PopupMenuItem(
                        value: 'collected',
                        child: Text('Mark collected'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
