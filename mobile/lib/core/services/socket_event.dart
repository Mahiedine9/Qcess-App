import 'dart:convert';

class SocketEvent {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final String timestamp;

  SocketEvent({
    required this.id,
    required this.type,
    required this.payload,
    required this.timestamp,
  });

  factory SocketEvent.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payloadMap =
        json['payload'] is Map ? Map<String, dynamic>.from(json['payload']) : {};

    return SocketEvent(
      id: json['id']?.toString() ?? '',
      type: (payloadMap['type'] ?? json['type'])?.toString() ?? '',
      payload: payloadMap,
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }

  static SocketEvent? fromFrameBody(String? body) {
    if (body == null) return null;
    try {
      final decoded = json.decode(body) as Map<String, dynamic>;
      return SocketEvent.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
