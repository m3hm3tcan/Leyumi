import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';

enum BackupFailure {
  noData,
  invalidPassword,
  invalidFile,
  unsupportedVersion,
  tooLarge,
}

class BackupException implements Exception {
  const BackupException(this.failure);

  final BackupFailure failure;
}

class BackupPreview {
  const BackupPreview({
    required this.createdAt,
    required this.profileCount,
    required this.recordCount,
  });

  final DateTime createdAt;
  final int profileCount;
  final int recordCount;
}

class BackupRestorePlan {
  const BackupRestorePlan._({required this.preview, required this.tables});

  final BackupPreview preview;
  final Map<String, List<Map<String, Object?>>> tables;
}

class BackupService {
  static const fileExtension = 'leyumi';
  static const mimeType = 'application/vnd.leyumi.backup';
  static const maxBackupBytes = 50 * 1024 * 1024;

  static const _envelopeFormat = 'leyumi-encrypted-backup';
  static const _payloadFormat = 'leyumi-backup-data';
  static const _formatVersion = 1;
  static const _argonMemory = 19456;
  static const _argonIterations = 2;
  static const _argonParallelism = 1;
  static const _saltLength = 16;
  static const _aad = <int>[
    108,
    101,
    121,
    117,
    109,
    105,
    45,
    98,
    97,
    99,
    107,
    117,
    112,
    45,
    118,
    49,
  ];

  final _cipher = AesGcm.with256bits();
  final _random = Random.secure();

  Future<Uint8List> createBackup(String password) async {
    _validatePassword(password);
    final tables = await _readCurrentTables();
    if (tables[AppDatabase.profilesTable]!.isEmpty) {
      throw const BackupException(BackupFailure.noData);
    }

    final payload = utf8.encode(
      jsonEncode({
        'format': _payloadFormat,
        'formatVersion': _formatVersion,
        'databaseSchemaVersion': AppDatabase.schemaVersion,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'tables': tables,
      }),
    );
    final salt = List<int>.generate(_saltLength, (_) => _random.nextInt(256));
    final secretKey = await _deriveKey(password, salt);
    final encrypted = await _cipher.encrypt(
      payload,
      secretKey: secretKey,
      aad: _aad,
    );
    final envelope = utf8.encode(
      jsonEncode({
        'format': _envelopeFormat,
        'formatVersion': _formatVersion,
        'kdf': {
          'name': 'argon2id',
          'memoryKiB': _argonMemory,
          'iterations': _argonIterations,
          'parallelism': _argonParallelism,
          'salt': base64Encode(salt),
        },
        'cipher': {
          'name': 'aes-256-gcm',
          'nonce': base64Encode(encrypted.nonce),
          'mac': base64Encode(encrypted.mac.bytes),
          'data': base64Encode(encrypted.cipherText),
        },
      }),
    );
    if (envelope.length > maxBackupBytes) {
      throw const BackupException(BackupFailure.tooLarge);
    }
    return Uint8List.fromList(envelope);
  }

  Future<BackupRestorePlan> prepareRestore(
    Uint8List bytes,
    String password,
  ) async {
    _validatePassword(password);
    if (bytes.isEmpty || bytes.length > maxBackupBytes) {
      throw BackupException(
        bytes.length > maxBackupBytes
            ? BackupFailure.tooLarge
            : BackupFailure.invalidFile,
      );
    }

    try {
      final envelope = _asStringMap(jsonDecode(utf8.decode(bytes)));
      _requireValue(envelope, 'format', _envelopeFormat);
      _requireValue(envelope, 'formatVersion', _formatVersion);
      final kdf = _asStringMap(envelope['kdf']);
      _requireValue(kdf, 'name', 'argon2id');
      _requireValue(kdf, 'memoryKiB', _argonMemory);
      _requireValue(kdf, 'iterations', _argonIterations);
      _requireValue(kdf, 'parallelism', _argonParallelism);
      final salt = base64Decode(kdf['salt'] as String);
      if (salt.length != _saltLength) throw const FormatException();

      final cipherData = _asStringMap(envelope['cipher']);
      _requireValue(cipherData, 'name', 'aes-256-gcm');
      final nonce = base64Decode(cipherData['nonce'] as String);
      final mac = base64Decode(cipherData['mac'] as String);
      final cipherText = base64Decode(cipherData['data'] as String);
      if (nonce.length != _cipher.nonceLength ||
          mac.length != _cipher.macAlgorithm.macLength) {
        throw const FormatException();
      }

      final key = await _deriveKey(password, salt);
      late final List<int> clearText;
      try {
        clearText = await _cipher.decrypt(
          SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
          secretKey: key,
          aad: _aad,
        );
      } on SecretBoxAuthenticationError {
        throw const BackupException(BackupFailure.invalidPassword);
      }

      final payload = _asStringMap(jsonDecode(utf8.decode(clearText)));
      _requireValue(payload, 'format', _payloadFormat);
      _requireValue(payload, 'formatVersion', _formatVersion);
      final schemaVersion = payload['databaseSchemaVersion'];
      if (schemaVersion is! int ||
          schemaVersion < 1 ||
          schemaVersion > AppDatabase.schemaVersion) {
        throw const BackupException(BackupFailure.unsupportedVersion);
      }
      final createdAt = DateTime.tryParse(
        payload['createdAt'] as String? ?? '',
      );
      if (createdAt == null) throw const FormatException();
      final tables = _validateTables(payload['tables']);
      final profiles = tables[AppDatabase.profilesTable]!;
      final recordCount = AppDatabase.recordTables.fold<int>(
        0,
        (total, table) => total + tables[table]!.length,
      );
      return BackupRestorePlan._(
        preview: BackupPreview(
          createdAt: createdAt.toLocal(),
          profileCount: profiles.length,
          recordCount: recordCount,
        ),
        tables: tables,
      );
    } on BackupException {
      rethrow;
    } on SecretBoxAuthenticationError {
      throw const BackupException(BackupFailure.invalidPassword);
    } on Object {
      throw const BackupException(BackupFailure.invalidFile);
    }
  }

  Future<void> restore(BackupRestorePlan plan) async {
    final database = await AppDatabase.instance;
    await database.transaction((transaction) async {
      await transaction.delete(AppDatabase.feedingDraftsTable);
      for (final table in AppDatabase.recordTables) {
        await transaction.delete(table);
      }
      await transaction.delete(AppDatabase.profilesTable);
      await transaction.delete(AppDatabase.metadataTable);

      for (final table in _tableColumns.keys) {
        for (final row in plan.tables[table]!) {
          await transaction.insert(
            table,
            row,
            conflictAlgorithm: ConflictAlgorithm.abort,
          );
        }
      }
    });
  }

  Future<Map<String, List<Map<String, Object?>>>> _readCurrentTables() async {
    final database = await AppDatabase.instance;
    final result = <String, List<Map<String, Object?>>>{};
    for (final entry in _tableColumns.entries) {
      final rows = await database.query(entry.key, columns: entry.value);
      result[entry.key] = rows
          .map((row) => Map<String, Object?>.from(row))
          .toList(growable: false);
    }
    return result;
  }

  Future<SecretKey> _deriveKey(String password, List<int> salt) => Argon2id(
    parallelism: _argonParallelism,
    memory: _argonMemory,
    iterations: _argonIterations,
    hashLength: 32,
  ).deriveKeyFromPassword(password: password, nonce: salt);

  void _validatePassword(String password) {
    if (password.length < 8 || password.length > 128) {
      throw const BackupException(BackupFailure.invalidPassword);
    }
  }

  Map<String, List<Map<String, Object?>>> _validateTables(Object? value) {
    final rawTables = _asStringMap(value);
    if (rawTables.length != _tableColumns.length ||
        !_tableColumns.keys.every(rawTables.containsKey)) {
      throw const FormatException();
    }

    var totalRows = 0;
    final tables = <String, List<Map<String, Object?>>>{};
    for (final entry in _tableColumns.entries) {
      final rawRows = rawTables[entry.key];
      if (rawRows is! List) throw const FormatException();
      totalRows += rawRows.length;
      if (totalRows > 200000) {
        throw const BackupException(BackupFailure.tooLarge);
      }
      tables[entry.key] = rawRows
          .map((row) => _validateRow(entry.key, row, entry.value))
          .toList(growable: false);
    }

    final profileIds = tables[AppDatabase.profilesTable]!
        .map((row) => row['id']! as String)
        .toSet();
    for (final table in AppDatabase.recordTables) {
      for (final row in tables[table]!) {
        if (!profileIds.contains(row['child_id'])) {
          throw const FormatException();
        }
      }
    }
    for (final row in tables[AppDatabase.feedingDraftsTable]!) {
      if (!profileIds.contains(row['child_id'])) {
        throw const FormatException();
      }
    }
    return tables;
  }

  Map<String, Object?> _validateRow(
    String table,
    Object? value,
    List<String> columns,
  ) {
    final row = _asStringMap(value);
    if (row.length != columns.length || !columns.every(row.containsKey)) {
      throw const FormatException();
    }
    for (final column in columns) {
      final field = row[column];
      if (column == 'sort_time') {
        if (field is! int) throw const FormatException();
      } else if (field is! String || field.isEmpty || field.length > 1000000) {
        throw const FormatException();
      }
    }
    final payload = row['payload'];
    if (payload is String) {
      if (jsonDecode(payload) is! Map) throw const FormatException();
    }
    return {for (final column in columns) column: row[column]};
  }

  Map<String, Object?> _asStringMap(Object? value) {
    if (value is! Map) throw const FormatException();
    return value.map((key, value) {
      if (key is! String) throw const FormatException();
      return MapEntry(key, value);
    });
  }

  void _requireValue(Map<String, Object?> map, String key, Object expected) {
    if (map[key] != expected) throw const FormatException();
  }

  static const _tableColumns = <String, List<String>>{
    AppDatabase.profilesTable: ['id', 'sort_time', 'payload'],
    AppDatabase.feedingTable: ['id', 'child_id', 'sort_time', 'payload'],
    AppDatabase.diaperTable: ['id', 'child_id', 'sort_time', 'payload'],
    AppDatabase.growthTable: ['id', 'child_id', 'sort_time', 'payload'],
    AppDatabase.milkBatchesTable: ['id', 'child_id', 'sort_time', 'payload'],
    AppDatabase.milkEventsTable: ['id', 'child_id', 'sort_time', 'payload'],
    AppDatabase.careEventsTable: ['id', 'child_id', 'sort_time', 'payload'],
    AppDatabase.feedingDraftsTable: ['child_id', 'payload'],
    AppDatabase.metadataTable: ['key', 'value'],
  };
}
