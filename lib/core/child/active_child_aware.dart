import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'active_child_provider.dart';

mixin ActiveChildAware<T extends StatefulWidget> on State<T> {
  String? _observedChildId;
  bool _hasObservedLoadedProvider = false;

  Future<void> onActiveChildChanged();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final children = context.watch<ActiveChildProvider>();
    if (!children.isLoaded) return;

    final childId = children.activeChildId;
    if (_hasObservedLoadedProvider && _observedChildId == childId) return;

    _hasObservedLoadedProvider = true;
    _observedChildId = childId;
    scheduleMicrotask(() {
      if (mounted) onActiveChildChanged();
    });
  }
}
