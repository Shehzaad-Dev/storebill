import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'card_tab.dart';

/// Full-screen business card editor (opened from Settings).
class BusinessCardPage extends StatelessWidget {
  const BusinessCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardTab(onLeave: () => context.pop()),
    );
  }
}
