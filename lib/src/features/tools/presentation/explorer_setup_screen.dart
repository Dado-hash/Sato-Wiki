import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'explorer_session.dart';
import 'explorer_widgets.dart';
import 'tool_widgets.dart';

/// Activation screen. It explains what the explorer sends and to whom, and
/// turns it on with one explicit button. When the explorer is on it shows the
/// state, lets the user change the server, and turns it off again.
class ExplorerSetupScreen extends StatefulWidget {
  const ExplorerSetupScreen({
    required this.settings,
    required this.session,
    super.key,
  });

  final AppSettingsController settings;
  final ExplorerSession session;

  @override
  State<ExplorerSetupScreen> createState() => _ExplorerSetupScreenState();
}

class _ExplorerSetupScreenState extends State<ExplorerSetupScreen> {
  late final TextEditingController _serverController;

  /// Set when the typed server was refused. Nothing is saved then.
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _serverController = TextEditingController(
      text: widget.settings.explorerServer,
    );
  }

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  /// Saves the typed server if it is allowed, returning false otherwise.
  Future<bool> _saveServer() async {
    final typed = _serverController.text.trim();
    if (parseExplorerServer(typed) == null) {
      setState(
        () => _serverError = AppLocalizations.of(context).explorerServerInvalid,
      );

      return false;
    }
    setState(() => _serverError = null);
    if (typed != widget.settings.explorerServer) {
      await widget.settings.setExplorerServer(typed);
    }

    return true;
  }

  Future<void> _turnOn() async {
    if (await _saveServer()) {
      await widget.settings.setExplorerEnabled(true);
    }
  }

  Future<void> _turnOff() async {
    await widget.settings.setExplorerEnabled(false);
    widget.session.close();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final enabled = widget.settings.explorerEnabled;
        final host = parseExplorerServer(widget.settings.explorerServer)?.host;

        return DetailScaffold(
          title: l10n.explorerSetupTitle,
          children: [
            if (enabled && host != null) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: StatusPill(
                  label: l10n.explorerStateOnServer(host),
                  color: context.sato.statusDeployed,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ] else if (!enabled) ...[
              Text(
                l10n.explorerSetupIntro,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              ExplorerNotice(
                text: l10n.explorerSetupWhatServerSees,
                warning: true,
              ),
              const SizedBox(height: AppSpacing.md),
              ExplorerNotice(text: l10n.explorerSetupOwnAddresses),
              const SizedBox(height: AppSpacing.md),
              ExplorerNotice(text: l10n.explorerSetupNothingSent),
              const SizedBox(height: AppSpacing.lg),
            ],
            ExplorerField(
              label: l10n.explorerServerField,
              child: ToolTextField(
                controller: _serverController,
                hintText: l10n.explorerServerField,
                errorText: _serverError,
                monospace: true,
                keyboardType: TextInputType.url,
                onChanged: (_) {
                  if (_serverError != null) {
                    setState(() => _serverError = null);
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.explorerServerHelp,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (enabled) ...[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
                onPressed: _saveServer,
                child: Text(l10n.explorerSaveServer),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.explorer),
                child: Text(l10n.explorerTitle),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
                onPressed: _turnOff,
                child: Text(l10n.explorerTurnOff),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.explorerTurnOffNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
                onPressed: _turnOn,
                child: Text(l10n.explorerTurnOn),
              ),
          ],
        );
      },
    );
  }
}
