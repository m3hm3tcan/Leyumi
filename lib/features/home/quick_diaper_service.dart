import '../../domain/repositories/diaper_repository.dart';
import '../../services/diaper_storage.dart';
import '../diaper/diaper_entry.dart';

class QuickDiaperService {
  QuickDiaperService({
    DiaperRepository? repository,
    DateTime Function()? clock,
    this.duplicateWindow = const Duration(seconds: 2),
  }) : _repository = repository ?? DiaperStorage(),
       _clock = clock ?? DateTime.now;

  final DiaperRepository _repository;
  final DateTime Function() _clock;
  final Duration duplicateWindow;

  bool _saving = false;
  DiaperType? _lastType;
  DateTime? _lastSavedAt;
  String? _lastSavedId;

  Future<DiaperEntry?> save({
    required String childId,
    required DiaperType type,
  }) async {
    if (_saving) return null;
    final now = _clock();
    final lastSavedAt = _lastSavedAt;
    if (_lastType == type &&
        lastSavedAt != null &&
        now.difference(lastSavedAt) < duplicateWindow) {
      return null;
    }

    _saving = true;
    try {
      final entry = DiaperEntry(childId: childId, timestamp: now, type: type);
      await _repository.addEntry(entry);
      _lastType = type;
      _lastSavedAt = now;
      _lastSavedId = entry.id;
      return entry;
    } finally {
      _saving = false;
    }
  }

  Future<void> undo(DiaperEntry entry) async {
    await _repository.deleteEntry(id: entry.id, childId: entry.childId);
    if (_lastSavedId == entry.id) {
      _lastType = null;
      _lastSavedAt = null;
      _lastSavedId = null;
    }
  }
}
