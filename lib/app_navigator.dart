import 'package:flutter/material.dart';

/// One global key for the app's Navigator.
///
/// The favorites panel lives ABOVE the Navigator (so it shows on every screen),
/// which means it has no Navigator in its BuildContext. This key lets it open
/// the detail page anyway.
final appNavigatorKey = GlobalKey<NavigatorState>();
