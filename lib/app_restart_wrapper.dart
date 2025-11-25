// lib/utils/app_restart_wrapper.dart

import 'package:flutter/material.dart';

/// A wrapper widget that allows the entire application below it to be rebuilt.
///
/// This provides a mechanism to "restart" the app's state by replacing its
/// child with a new instance.
class AppRestartWrapper extends StatefulWidget {
  final Widget child;

  const AppRestartWrapper({super.key, required this.child});

  /// Finds the AppRestartWrapper's state in the widget tree and calls its
  /// restartApp method.
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_AppRestartWrapperState>()?.restartApp();
  }

  @override
  State<AppRestartWrapper> createState() => _AppRestartWrapperState();
}

class _AppRestartWrapperState extends State<AppRestartWrapper> {
  Key _key = UniqueKey();

  /// Changes the key of the child widget.
  ///
  /// When Flutter's build method encounters a widget with a different key
  /// than the previous one, it discards the old widget's state and creates
  /// a new one, effectively restarting it.
  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    // We use a KeyedSubtree to ensure that changing the key forces a full rebuild
    // of the widget.child.
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
