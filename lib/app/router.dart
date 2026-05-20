import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/app_repository.dart';
import '../screens/business_card_page.dart';
import '../screens/invoice_history_page.dart';
import '../screens/khata_add_customer_page.dart';
import '../screens/khata_customer_detail_page.dart';
import '../screens/legal_about_page.dart';
import '../screens/legal_privacy_page.dart';
import '../screens/legal_terms_page.dart';
import '../screens/main_shell.dart';
import '../screens/notifications_page.dart';
import '../screens/onboarding_screen.dart';
import '../screens/receipt_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createAppRouter(AppRepository repo) {
  final onboardingDone = repo.load().onboardingComplete;
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: onboardingDone ? '/' : '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/', builder: (_, _) => const MainShell()),
      GoRoute(path: '/receipt', builder: (_, _) => const ReceiptPage()),
      GoRoute(path: '/history', builder: (_, _) => const InvoiceHistoryPage()),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsPage(),
      ),
      GoRoute(path: '/card', builder: (_, _) => const BusinessCardPage()),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyPolicyPage()),
      GoRoute(path: '/terms', builder: (_, _) => const TermsPage()),
      GoRoute(path: '/about', builder: (_, _) => const AboutPage()),
      GoRoute(
        path: '/khata/add',
        builder: (_, _) => const KhataAddCustomerPage(),
      ),
      GoRoute(
        path: '/khata/customer/:id',
        builder: (ctx, st) {
          final id = st.pathParameters['id'] ?? '';
          return KhataCustomerDetailPage(customerId: id);
        },
      ),
    ],
  );
}
