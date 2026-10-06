import 'package:flutter/material.dart';

/// Shared fade page transition for a smooth, futuristic feel.
Route fadeRoute(Widget page) => PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: page),
    );
