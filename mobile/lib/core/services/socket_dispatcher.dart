import 'dart:async';
import 'package:mobile/core/services/socket_event.dart';
import 'package:mobile/core/services/socket_service.dart';

class SocketDispatcher {
  StreamSubscription<SocketEvent>? _sub;
  final _controller = StreamController<SocketEvent>.broadcast();

  SocketDispatcher();

  Stream<SocketEvent> get events => _controller.stream;

  Stream<SocketEvent> onType(String type) => events.where((e) => e.type == type);

  void bind(SocketService socket) {
    _sub?.cancel();
    _sub = socket.events.listen(
      _controller.add,
      onError: _controller.addError,
    );
  }

  void unbind() {
    _sub?.cancel();
    _sub = null;
  }

  void dispose() {
    unbind();
    _controller.close();
  }
}
