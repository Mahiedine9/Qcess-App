import 'dart:async';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/core/services/socket_event.dart';
import 'package:mobile/features/auth/data/repositories/token_storage_service.dart';

class SocketService {
  final String websocketUrl;
  StompClient? _client;
  final _controller = StreamController<SocketEvent>.broadcast();

  SocketService({required this.websocketUrl});

  Stream<SocketEvent> get events => _controller.stream;

  Future<void> connect({String? jwt}) async {
    if (_client != null && _client!.connected) {
      print('[SocketService] 🔄 Already connected to $websocketUrl');
      return;
    }

    print('[SocketService] 🔌 Connecting to $websocketUrl ...');

    final token = jwt ?? await sl<TokenStorageService>().getToken();
    print('[SocketService] 🔐 Using token present: ${token != null}');

    _client = StompClient(
      config: StompConfig.sockJS(
        url: websocketUrl,
        beforeConnect: () async {
          print('[SocketService] ⏳ beforeConnect');
        },
        onConnect: (frame) {
          print('[SocketService] ✅ STOMP connected');
          print('[SocketService] Subscribing to /user/queue/notifications and /topic/notifications');

          _client!.subscribe(
            destination: '/user/queue/notifications',
            callback: _onFrame,
          );
          _client!.subscribe(
            destination: '/topic/notifications',
            callback: _onFrame,
          );
        },
        stompConnectHeaders:
            token != null ? {'Authorization': 'Bearer $token'} : {},
        webSocketConnectHeaders:
            token != null ? {'Authorization': 'Bearer $token'} : {},
        onWebSocketError: (err) {
          print('[SocketService] ❌ WebSocket error: $err');
          _controller.addError(err);
        },
        onStompError: (frame) {
          print('[SocketService] ❌ STOMP error: ${frame.body}');
          _controller.addError(frame.body ?? 'STOMP error');
        },
        onDisconnect: (frame) {
          print('[SocketService] 🔌 STOMP disconnected');
        },
        onWebSocketDone: () {
          print('[SocketService] 🔚 WebSocket closed');
        },
        heartbeatIncoming: const Duration(seconds: 0),
        heartbeatOutgoing: const Duration(seconds: 0),
      ),
    );

    _client!.activate();
  }

  void _onFrame(StompFrame frame) {
    final socketEvent = SocketEvent.fromFrameBody(frame.body);
    if (socketEvent != null) {
      print('[SocketService] 🔁 Parsed SocketEvent: ${socketEvent.type}');
      _controller.add(socketEvent);
    } else {
      print('[SocketService] ⚠️ Unable to parse frame body to SocketEvent');
    }
  }

  Future<void> disconnect() async {
    print('[SocketService] 🔌 Disconnecting from $websocketUrl ...');
    try {
      _client?.deactivate();
    } catch (e) {
      print('[SocketService] ⚠️ Error while disconnecting: $e');
    }
    _client = null;
  }

  void dispose() => disconnect();
}
