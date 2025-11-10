import 'dart:async';
import 'package:flutter/material.dart';

class RouterRefresh extends ChangeNotifier {
  RouterRefresh(List<Stream<dynamic>> streams) {
    for (var stream in streams) {
      final subscription = stream.asBroadcastStream().listen((_) {
        notifyListeners();
      });
      _subscriptions.add(subscription);
    }
  }

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
