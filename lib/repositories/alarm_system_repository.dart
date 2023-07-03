import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:alarmapp_pwa/models/alarm_state.dart';
import 'package:alarmapp_pwa/models/area_state.dart';
import 'package:http/http.dart' as http;

const String _baseUrl = 'api.particle.io';

class AlarmSystemRepository {
  AlarmSystemRepository({required this.accessToken, required this.deviceId});

  final String accessToken;
  final String deviceId;
  EventSource? events;

  void startAlarmStateStream(Function(AlarmState) callback) {
    final url = Uri.https(
        _baseUrl, '/v1/events/systemState', {'access_token': accessToken});
    events?.close();
    events = EventSource(url.toString());
    events?.addEventListener('systemState', (event) {
      final data = jsonDecode((event as MessageEvent).data)['data'];
      final state = parseState(data);

      callback(state);
    });
  }

  Future<AlarmState> getSystemState() {
    final url = Uri.https(_baseUrl, '/v1/devices/$deviceId/systemState',
        {'access_token': accessToken});

    return http.get(url).then((response) {
      return parseState(jsonDecode(response.body)['result']);
    });
  }

  Future<dynamic> activateSystem(Set<int> areas, Set<int> disabledAreas) {
    final url = Uri.https(
        _baseUrl, '/v1/devices/events', {'access_token': accessToken});

    final body = {
      'name': 'activateSystem',
      'data': areas
          .map((area) => "$area${disabledAreas.contains(area) ? 'd' : 'e'}")
          .join('-'),
      'private': 'true',
      'ttl': '60',
    };

    return http
        .post(url, body: body)
        .then((response) => jsonDecode(response.body));
  }

  Future<dynamic> deactivateSystem() {
    final url = Uri.https(
        _baseUrl, '/v1/devices/events', {'access_token': accessToken});

    final body = {
      'name': 'deactivateSystem',
      'data': '',
      'private': 'true',
      'ttl': '60',
    };

    return http
        .post(url, body: body)
        .then((response) => jsonDecode(response.body));
  }

  Future<dynamic> testSiren() {
    final url = Uri.https(
        _baseUrl, '/v1/devices/events', {'access_token': accessToken});

    final body = {
      'name': 'testSiren',
      'data': '',
      'private': 'true',
      'ttl': '60',
    };

    return http
        .post(url, body: body)
        .then((response) => jsonDecode(response.body));
  }

  Future<dynamic> postPanic() {
    final url = Uri.https(
        _baseUrl, '/v1/devices/events', {'access_token': accessToken});

    final body = {
      'name': 'triggerPanic',
      'data': '',
      'private': 'true',
      'ttl': '60',
    };

    return http
        .post(url, body: body)
        .then((response) => jsonDecode(response.body));
  }
}

AlarmState parseState(String state) {
  final [areasState, sirenState, systemState] = state.split('|');
  final areas = areasState.split('-').asMap().entries.map((entry) => AreaState(
        areaNumber: entry.key + 1,
        isOpen: entry.value.contains('0'),
        isDisabled: entry.value.contains('d'),
      ));
  final sirenIsActive = sirenState.contains('1');
  final systemIsActive = systemState.contains('1');

  return AlarmState(
    areas: areas.map((area) => area.areaNumber).toSet(),
    disabledAreas: areas
        .where((area) => area.isDisabled)
        .map((area) => area.areaNumber)
        .toSet(),
    openAreas: areas
        .where((area) => area.isOpen)
        .map((area) => area.areaNumber)
        .toSet(),
    isArmed: systemIsActive,
    hasSirenActive: sirenIsActive,
  );
}
