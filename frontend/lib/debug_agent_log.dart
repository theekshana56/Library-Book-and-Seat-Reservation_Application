import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

void agentDebugLog({
  required String location,
  required String message,
  required String hypothesisId,
  Map<String, Object?> data = const {},
  String runId = 'pre-fix',
}) {
  // #region agent log
  final payload = {
    'sessionId': '60ec8f',
    'runId': runId,
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };
  final body = jsonEncode(payload);
  debugPrint('AGENT_DEBUG_60ec8f $body');
  const path = '/ingest/8dc13413-b16c-405c-854f-280d4118c3eb';
  final headers = {
    'Content-Type': 'application/json',
    'X-Debug-Session-Id': '60ec8f',
  };
  for (final host in ['127.0.0.1', '10.0.2.2', '192.168.1.5']) {
    http
        .post(
          Uri.parse('http://$host:7488$path'),
          headers: headers,
          body: body,
        )
        .timeout(const Duration(seconds: 3))
        .then((_) {}, onError: (_) {});
  }
  // #endregion
}
