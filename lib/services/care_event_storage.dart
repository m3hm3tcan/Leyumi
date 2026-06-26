import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/data/json_record_decoder.dart';
import '../features/care_calendar/care_event.dart';
import 'active_child_scope.dart';

class CareEventStorage {
  static const key = 'care_calendar_events_v1';

  Future<List<CareEvent>> loadEvents() async {
    final events = await _loadAll();
    final filtered = await ActiveChildScope.filter(
      events,
      (event) => event.childId,
    );
    filtered.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return filtered;
  }

  Future<void> save(CareEvent event) async {
    final events = await _loadAll();
    final index = events.indexWhere((item) => item.id == event.id);
    if (index < 0) {
      events.add(event);
    } else {
      events[index] = event;
    }
    await _saveAll(events);
  }

  Future<void> delete(String eventId) async {
    final events = await _loadAll();
    events.removeWhere((event) => event.id == eventId);
    await _saveAll(events);
  }

  Future<void> deleteChildData(String childId) async {
    final events = await _loadAll();
    events.removeWhere((event) => event.childId == childId);
    await _saveAll(events);
  }

  Future<List<CareEvent>> _loadAll() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(key);
    if (raw == null || raw.isEmpty) return [];
    return JsonRecordDecoder.decodeArray(
      value: raw,
      fromJson: CareEvent.fromJson,
      source: 'care calendar',
    );
  }

  Future<void> _saveAll(List<CareEvent> events) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      key,
      jsonEncode(events.map((event) => event.toJson()).toList()),
    );
  }
}
