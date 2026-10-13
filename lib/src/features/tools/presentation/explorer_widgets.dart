import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../data/esplora_client.dart';
import '../domain/units.dart';
import 'explorer_session.dart';
import 'tool_widgets.dart';

/// Wait used when the server gives no Retry-After value.
const Duration _fallbackWait = Duration(seconds: 60);

/// Whole seconds to wait, at least 1, for the rate-limit message.
int explorerWaitSeconds(Duration? wait) {
  final seconds = (wait ?? _fallbackWait).inMilliseconds / 1000;

  return seconds.ceil() < 1 ? 1 : seconds.ceil();
}

/// User-facing text for a failed explorer call.
String explorerErrorText(AppLocalizations l10n, ExplorerException error) {
  return switch (error.failure) {
    ExplorerFailure.invalidInput => l10n.explorerInvalidInput,
    ExplorerFailure.notFound => l10n.explorerNotFound,
    ExplorerFailure.network ||
    ExplorerFailure.timeout => l10n.explorerNetworkError,
    ExplorerFailure.badResponse => l10n.explorerBadResponse,
    ExplorerFailure.rateLimited || ExplorerFailure.lockedOut =>
      l10n.explorerRateLimited(explorerWaitSeconds(error.retryAfter)),
  };
}

/// Amount in BTC and satoshi, for example "0.50000000 BTC · 50000000 sat".
String explorerAmountText(AppLocalizations l10n, int satoshi) {
  return l10n.explorerAmount(satoshiToBitcoinText(satoshi), '$satoshi');
}

/// UTC date and time of a Unix timestamp, in a fixed numeric form.
String explorerUtcTime(int unixSeconds) {
  final time = DateTime.fromMillisecondsSinceEpoch(
    unixSeconds * 1000,
    isUtc: true,
  );
  String two(int value) => value.toString().padLeft(2, '0');

  return '${time.year}-${two(time.month)}-${two(time.day)} '
      '${two(time.hour)}:${two(time.minute)} UTC';
}

/// True for the failures that pause calls for a while.
bool explorerIsRateLimit(ExplorerException error) {
  return error.failure == ExplorerFailure.rateLimited ||
      error.failure == ExplorerFailure.lockedOut;
}

/// Boxed text for an explorer message. A warning uses the accent colours. An
/// error uses the error colour with its text, so the state is not shown by
/// colour alone.
class ExplorerNotice extends StatelessWidget {
  const ExplorerNotice({
    required this.text,
    this.title,
    this.warning = false,
    super.key,
  });

  final String text;
  final String? title;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: warning
            ? context.sato.accentTint
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: warning ? colorScheme.primary : colorScheme.error,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(title!, style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text(text, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// Small label above a value, such as "HASH" above a block hash.
class ExplorerField extends StatelessWidget {
  const ExplorerField({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

/// Monospace link to another explorer screen, such as a txid or an address.
/// Tapping it is a user action, so it sends one request when the target
/// screen opens.
class ExplorerLink extends StatelessWidget {
  const ExplorerLink({required this.value, required this.onTap, super.key});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.thumb),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            value,
            style: toolMonoStyle(context).copyWith(
              color: colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown instead of data when the explorer is off, or its server is not
/// allowed. Leads to the setup screen.
class ExplorerOffNotice extends StatelessWidget {
  const ExplorerOffNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExplorerNotice(text: l10n.explorerOffBody),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.explorerSetup),
          child: Text(l10n.explorerTurnOn, style: textTheme.labelLarge),
        ),
      ],
    );
  }
}

/// Loads one explorer result when it is built, and again only when the user
/// presses retry. There is no polling and no automatic retry.
class ExplorerLoader<T> extends StatefulWidget {
  const ExplorerLoader({
    required this.session,
    required this.load,
    required this.builder,
    super.key,
  });

  final ExplorerSession session;
  final Future<T> Function(ExplorerApi api) load;
  final Widget Function(BuildContext context, T value) builder;

  @override
  State<ExplorerLoader<T>> createState() => _ExplorerLoaderState<T>();
}

class _ExplorerLoaderState<T> extends State<ExplorerLoader<T>> {
  final _cooldown = ExplorerCooldown();

  T? _value;
  ExplorerException? _error;
  bool _loading = false;
  bool _off = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void dispose() {
    _cooldown.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final api = widget.session.activeApi();
    if (api == null) {
      setState(() => _off = true);

      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final value = await widget.load(api);
      if (!mounted) {
        return;
      }
      setState(() {
        _value = value;
        _loading = false;
      });
    } on ExplorerException catch (error) {
      _fail(error);
    } on Object {
      _fail(
        const ExplorerException(
          ExplorerFailure.badResponse,
          'Unexpected explorer error.',
        ),
      );
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
      _cooldown.start(error.retryAfter ?? _fallbackWait, () {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = _value;
    final error = _error;

    if (_off) {
      return const ExplorerOffNotice();
    }
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          children: [
            const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(l10n.explorerLoading),
          ],
        ),
      );
    }
    if (error != null) {
      return ExplorerErrorView(
        error: error,
        onRetry: _cooldown.active ? null : _run,
      );
    }
    if (value != null) {
      return widget.builder(context, value);
    }

    return const SizedBox.shrink();
  }
}

/// Error message for a failed call. Retry is offered for network and server
/// failures, and disabled while a rate-limit wait runs.
class ExplorerErrorView extends StatelessWidget {
  const ExplorerErrorView({required this.error, this.onRetry, super.key});

  final ExplorerException error;

  /// Null disables the retry button.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canRetry =
        error.failure != ExplorerFailure.notFound &&
        error.failure != ExplorerFailure.invalidInput;
    final rateLimited = explorerIsRateLimit(error);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExplorerNotice(text: explorerErrorText(l10n, error)),
        if (rateLimited) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.explorerNoAutoRetry,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (canRetry) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
            onPressed: onRetry,
            child: Text(l10n.explorerRetry),
          ),
        ],
      ],
    );
  }
}
