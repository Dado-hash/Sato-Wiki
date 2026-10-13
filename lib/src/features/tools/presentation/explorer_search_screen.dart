import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../data/esplora_client.dart';
import '../data/explorer_query.dart';
import '../domain/address_analyzer.dart';
import 'explorer_session.dart';
import 'explorer_widgets.dart';
import 'tool_widgets.dart';

/// Explorer search. One input for a block height, a block hash, a txid or an
/// address. The search sends only what the query needs, then opens the screen
/// for the result. Keys and private data are never sent.
class ExplorerSearchScreen extends StatefulWidget {
  const ExplorerSearchScreen({
    required this.settings,
    required this.session,
    super.key,
  });

  final AppSettingsController settings;
  final ExplorerSession session;

  @override
  State<ExplorerSearchScreen> createState() => _ExplorerSearchScreenState();
}

class _ExplorerSearchScreenState extends State<ExplorerSearchScreen> {
  final _controller = TextEditingController();
  final _cooldown = ExplorerCooldown();

  bool _loading = false;

  /// Failure of the last search, shown below the input.
  ExplorerException? _error;

  /// Set after a private or extended key was pasted and cleared.
  AddressKind? _secretKind;

  @override
  void dispose() {
    _cooldown.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final kind = analyzeAddress(value.trim()).kind;
    if (kind == AddressKind.privateKeyWif || kind == AddressKind.extendedKey) {
      // A pasted key is cleared at once: it is never analysed, sent or kept.
      _controller.clear();
      setState(() {
        _error = null;
        _secretKind = kind;
      });

      return;
    }

    if (_error != null || _secretKind != null) {
      setState(() {
        _error = null;
        _secretKind = null;
      });
    } else {
      setState(() {});
    }
  }

  bool get _canSearch =>
      !_loading && !_cooldown.active && _controller.text.trim().isNotEmpty;

  Future<void> _search() async {
    final text = _controller.text.trim();
    final kind = analyzeAddress(text).kind;
    if (kind == AddressKind.privateKeyWif || kind == AddressKind.extendedKey) {
      // Keys are never analysed, sent or kept. The field is emptied first.
      _controller.clear();
      setState(() {
        _error = null;
        _secretKind = kind;
      });

      return;
    }

    final query = parseExplorerQuery(text);
    final api = widget.session.activeApi();
    if (query == null || api == null) {
      setState(() {
        _secretKind = null;
        _error = query == null
            ? const ExplorerException(
                ExplorerFailure.invalidInput,
                'Input is not a height, hash or address.',
              )
            : const ExplorerException(
                ExplorerFailure.badResponse,
                'The stored explorer server is not allowed.',
              );
      });

      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _secretKind = null;
    });

    try {
      final route = await _resolve(api, query);
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      if (route == null) {
        setState(() {
          _error = const ExplorerException(
            ExplorerFailure.notFound,
            'Neither a transaction nor a block has this id.',
          );
        });
      } else {
        unawaited(Navigator.of(context).pushNamed(route));
      }
    } on ExplorerException catch (error) {
      _fail(error);
    }
  }

  void _fail(ExplorerException error) {
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _error = error;
    });
    if (explorerIsRateLimit(error)) {
      _cooldown.start(error.retryAfter ?? const Duration(seconds: 60), () {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  /// Route of the screen that shows the result, or null when the server does
  /// not know the id. A height is turned into its block hash here, so the
  /// block screen only asks for the block.
  Future<String?> _resolve(ExplorerApi api, ExplorerQuery query) async {
    switch (query) {
      case ExplorerAddressQuery(:final address):
        return AppRoutes.explorerAddress(address);
      case ExplorerHeightQuery(:final height):
        final hash = await api.blockHashAtHeight(height);

        return AppRoutes.explorerBlock(hash);
      case ExplorerHashQuery hashQuery:
        return _resolveHash(
          api,
          hashQuery.hash,
          blockFirst: hashQuery.looksLikeBlockHash,
        );
    }
  }

  /// A 64-character id is a txid or a block hash. Blocks are tried first only
  /// when the id has the leading zeros of a block hash. A "not found" from the
  /// first try leads to the second try, and nothing else is sent.
  Future<String?> _resolveHash(
    ExplorerApi api,
    String hash, {
    required bool blockFirst,
  }) async {
    final order = blockFirst ? [true, false] : [false, true];
    for (final asBlock in order) {
      try {
        if (asBlock) {
          await api.block(hash);

          return AppRoutes.explorerBlock(hash);
        }
        await api.transaction(hash);

        return AppRoutes.explorerTransaction(hash);
      } on ExplorerException catch (error) {
        if (error.failure != ExplorerFailure.notFound) {
          rethrow;
        }
      }
    }

    return null;
  }

  void _turnOff() {
    widget.session.close();
    unawaited(widget.settings.setExplorerEnabled(false));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _error;
    final secretKind = _secretKind;

    return DetailScaffold(
      title: l10n.explorerTitle,
      actions: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
          onPressed: _turnOff,
          child: Text(l10n.explorerTurnOff),
        ),
      ],
      children: [
        Text(
          l10n.explorerServerInUse(widget.settings.explorerServer),
          style: toolMonoStyle(context, size: 12),
        ),
        const SizedBox(height: AppSpacing.lg),
        ToolTextField(
          controller: _controller,
          hintText: l10n.explorerSearchHint,
          onChanged: _onChanged,
          monospace: true,
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
          onPressed: _canSearch ? _search : null,
          child: Text(l10n.explorerSearchButton),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_loading)
          Text(
            l10n.explorerLookingUp,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else if (secretKind != null)
          ExplorerNotice(
            warning: true,
            title: secretKind == AddressKind.extendedKey
                ? l10n.explorerSecretExtendedTitle
                : l10n.explorerSecretWifTitle,
            text: l10n.explorerSecretBody,
          )
        else if (error != null) ...[
          ExplorerNotice(text: explorerErrorText(l10n, error)),
          if (explorerIsRateLimit(error)) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.explorerNoAutoRetry,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.explorerSearchNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
