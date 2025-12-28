import 'package:mobile/core/services/socket_dispatcher.dart';
import 'package:mobile/core/services/socket_service.dart';
import 'package:mobile/core/services/ticket_socket_listener.dart';
import 'package:mobile/features/maintenance/logic/bloc/tickets_bloc.dart';

class RealtimeSessionManager {
  final SocketService socket;
  final SocketDispatcher dispatcher;
  TicketSocketListener? _ticketListener;

  RealtimeSessionManager({
    required this.socket,
    required this.dispatcher,
  });

  Future<void> start({
    required TicketsBloc ticketsBloc,
    String? jwt,
  }) async {
    print('[RealtimeSessionManager] ▶️ start called');

    await socket.connect(jwt: jwt);
    dispatcher.bind(socket);

    _ticketListener = TicketSocketListener(
      dispatcher: dispatcher,
      bloc: ticketsBloc,
    );
  }

  Future<void> stop() async {
    _ticketListener?.dispose();
    _ticketListener = null;

    dispatcher.unbind();
    await socket.disconnect();
  }
}
