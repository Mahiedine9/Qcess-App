import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/core/services/socket_dispatcher.dart';
import 'package:mobile/core/services/socket_event.dart';
import 'package:mobile/features/maintenance/logic/bloc/tickets_bloc.dart';
import 'package:mobile/features/maintenance/logic/bloc/tickets_event.dart';


class TicketSocketListener {
  final SocketDispatcher dispatcher;
  final TicketsBloc bloc;
  final List<StreamSubscription<SocketEvent>> _subs = [];

  TicketSocketListener({required this.dispatcher, required this.bloc}) {
    final handler = _refreshTicket;
    _subs.add(dispatcher.onType('TICKET_CREATED').listen((e) {
      try {
        debugPrint('[Socket] TICKET_CREATED received: ${e.payload}');
      } catch (_) {}
      handler(e);
    }));
    _subs.add(dispatcher.onType('TICKET_STATUS_CHANGED').listen((e) {
      try {
        debugPrint('[Socket] TICKET_STATUS_CHANGED received: ${e.payload}');
      } catch (_) {}
      handler(e);
    }));
    _subs.add(dispatcher.onType('TICKET_COMMENT_ADDED').listen((e) {
      try {
        debugPrint('[Socket] TICKET_COMMENT_ADDED received: ${e.payload}');
      } catch (_) {}
      handler(e);
    }));
  }

  int? _extractId(Map<String, dynamic> payload) {
    if (payload['ticketId'] != null) return int.tryParse(payload['ticketId'].toString());
    if (payload['ticket_id'] != null) return int.tryParse(payload['ticket_id'].toString());
    if (payload['id'] != null) return int.tryParse(payload['id'].toString());
    return null;
  }

  void _refreshTicket(SocketEvent e) {
    final id = _extractId(e.payload);
    bloc.add(id != null ? TicketDetailRequested(id) : const TicketsRequested());
  }

  void dispose() {
    for (final s in _subs) {
      try {
        s.cancel();
      } catch (_) {}
    }
    _subs.clear();
  }
}
