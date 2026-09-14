import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/child/active_child_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/backup_service.dart';

class DataBackupScreen extends StatefulWidget {
  const DataBackupScreen({super.key});

  @override
  State<DataBackupScreen> createState() => _DataBackupScreenState();
}

class _DataBackupScreenState extends State<DataBackupScreen> {
  final _service = BackupService();
  bool _isBusy = false;

  Future<void> _createBackup() async {
    final l10n = AppLocalizations.of(context);
    final password = await showDialog<String>(
      context: context,
      builder: (_) => _BackupPasswordDialog(
        title: l10n.createBackupPassword,
        confirmPassword: true,
      ),
    );
    if (password == null || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final bytes = await _service.createBackup(password);
      if (!mounted) return;
      final now = DateTime.now();
      final date = [
        now.year.toString().padLeft(4, '0'),
        now.month.toString().padLeft(2, '0'),
        now.day.toString().padLeft(2, '0'),
      ].join('-');
      final saved = await FilePicker.saveFile(
        fileName: 'leyumi-backup-$date.${BackupService.fileExtension}',
        bytes: bytes,
        mimeType: BackupService.mimeType,
        dialogTitle: l10n.backupData,
      );
      if (saved == null || !mounted) return;
      _showMessage(l10n.backupSaved);
    } catch (error) {
      if (!mounted) return;
      _showMessage(_errorMessage(error, l10n));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _restoreBackup() async {
    final l10n = AppLocalizations.of(context);
    final file = await FilePicker.pickFile(
      dialogTitle: l10n.restoreData,
      type: FileType.custom,
      allowedExtensions: const [BackupService.fileExtension],
    );
    if (file == null || !mounted) return;

    final password = await showDialog<String>(
      context: context,
      builder: (_) => _BackupPasswordDialog(
        title: l10n.restoreBackupPassword,
        confirmPassword: false,
      ),
    );
    if (password == null || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final length = await file.length();
      if (length > BackupService.maxBackupBytes) {
        throw const BackupException(BackupFailure.tooLarge);
      }
      final bytes = await file.readAsBytes();
      final plan = await _service.prepareRestore(
        Uint8List.fromList(bytes),
        password,
      );
      if (!mounted) return;
      setState(() => _isBusy = false);

      final material = MaterialLocalizations.of(context);
      final createdAt = plan.preview.createdAt;
      final createdLabel =
          '${material.formatMediumDate(createdAt)} '
          '${material.formatTimeOfDay(TimeOfDay.fromDateTime(createdAt))}';
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.restoreBackupTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.restoreBackupSummary(
                  createdLabel,
                  plan.preview.profileCount,
                  plan.preview.recordCount,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.restoreBackupWarning,
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.error,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.restoreNow),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      setState(() => _isBusy = true);
      await _service.restore(plan);
      if (!mounted) return;
      await context.read<ActiveChildProvider>().reload();
      if (!mounted) return;
      _showMessage(l10n.restoreComplete);
    } catch (error) {
      if (!mounted) return;
      _showMessage(_errorMessage(error, l10n));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  String _errorMessage(Object error, AppLocalizations l10n) {
    if (error is! BackupException) return l10n.backupOperationFailed;
    return switch (error.failure) {
      BackupFailure.noData => l10n.backupNoData,
      BackupFailure.invalidPassword => l10n.backupInvalidPassword,
      BackupFailure.invalidFile => l10n.backupInvalidFile,
      BackupFailure.unsupportedVersion => l10n.backupUnsupportedVersion,
      BackupFailure.tooLarge => l10n.backupTooLarge,
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dataManagement)),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.backup_outlined),
                      title: Text(l10n.backupData),
                      subtitle: Text(l10n.backupDataDescription),
                      trailing: const Icon(Icons.chevron_right),
                      enabled: !_isBusy,
                      onTap: _createBackup,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.restore_outlined),
                      title: Text(l10n.restoreData),
                      subtitle: Text(l10n.restoreDataDescription),
                      trailing: const Icon(Icons.chevron_right),
                      enabled: !_isBusy,
                      onTap: _restoreBackup,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.backupPasswordRequirement,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (_isBusy)
            const ColoredBox(
              color: Color(0x33000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _BackupPasswordDialog extends StatefulWidget {
  const _BackupPasswordDialog({
    required this.title,
    required this.confirmPassword,
  });

  final String title;
  final bool confirmPassword;

  @override
  State<_BackupPasswordDialog> createState() => _BackupPasswordDialogState();
}

class _BackupPasswordDialogState extends State<_BackupPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _passwordController,
                autofocus: true,
                obscureText: _obscurePassword,
                maxLength: 128,
                textInputAction: widget.confirmPassword
                    ? TextInputAction.next
                    : TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.backupPassword,
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) => (value?.length ?? 0) < 8
                    ? l10n.backupPasswordRequirement
                    : null,
                onFieldSubmitted: (_) {
                  if (!widget.confirmPassword) _submit();
                },
              ),
              if (widget.confirmPassword) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmationController,
                  obscureText: _obscurePassword,
                  maxLength: 128,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.confirmBackupPassword,
                  ),
                  validator: (value) => value != _passwordController.text
                      ? l10n.backupPasswordsDoNotMatch
                      : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                l10n.backupPasswordRequirement,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.continueLabel)),
      ],
    );
  }
}
