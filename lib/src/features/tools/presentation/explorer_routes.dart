import 'package:flutter/widgets.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/settings/app_settings_controller.dart';
import 'explorer_address_screen.dart';
import 'explorer_block_screen.dart';
import 'explorer_search_screen.dart';
import 'explorer_session.dart';
import 'explorer_setup_screen.dart';
import 'explorer_transaction_screen.dart';

/// An explorer route name, parsed from the path. The values are not checked
/// here: the client checks every hash, txid and address before it is sent.
sealed class ExplorerRoute {
  const ExplorerRoute();

  /// Parses an explorer route name, or returns null for any other route.
  static ExplorerRoute? tryParse(String routeName) {
    final segments = Uri.tryParse(routeName)?.pathSegments;
    if (segments == null || segments.length < 2) {
      return null;
    }
    if (segments[0] != 'code' || segments[1] != 'explorer') {
      return null;
    }

    final rest = segments.sublist(2);
    if (rest.isEmpty) {
      return const ExplorerSearchRoute();
    }
    if (rest.length == 1 && rest[0] == 'setup') {
      return const ExplorerSetupRoute();
    }
    if (rest.length == 2) {
      return switch (rest[0]) {
        'block' => ExplorerBlockRoute(rest[1]),
        'tx' => ExplorerTransactionRoute(rest[1]),
        'address' => ExplorerAddressRoute(rest[1]),
        _ => null,
      };
    }

    return null;
  }
}

final class ExplorerSearchRoute extends ExplorerRoute {
  const ExplorerSearchRoute();
}

final class ExplorerSetupRoute extends ExplorerRoute {
  const ExplorerSetupRoute();
}

final class ExplorerBlockRoute extends ExplorerRoute {
  const ExplorerBlockRoute(this.hash);

  final String hash;
}

final class ExplorerTransactionRoute extends ExplorerRoute {
  const ExplorerTransactionRoute(this.txid);

  final String txid;
}

final class ExplorerAddressRoute extends ExplorerRoute {
  const ExplorerAddressRoute(this.address);

  final String address;
}

/// The screen for an explorer route. While the explorer is off every explorer
/// route shows the activation screen, and no client is created.
Widget explorerScreenFor(
  ExplorerRoute route,
  AppSettingsController settings,
  ContentStore store,
) {
  final session = ExplorerSession.of(settings);
  if (route is ExplorerSetupRoute || !settings.explorerEnabled) {
    return ExplorerSetupScreen(settings: settings, session: session);
  }

  return switch (route) {
    ExplorerSearchRoute() => ExplorerSearchScreen(
      settings: settings,
      session: session,
    ),
    ExplorerBlockRoute(:final hash) => ExplorerBlockScreen(
      session: session,
      store: store,
      hash: hash,
    ),
    ExplorerTransactionRoute(:final txid) => ExplorerTransactionScreen(
      session: session,
      store: store,
      txid: txid,
    ),
    ExplorerAddressRoute(:final address) => ExplorerAddressScreen(
      session: session,
      store: store,
      address: address,
    ),
    ExplorerSetupRoute() => ExplorerSetupScreen(
      settings: settings,
      session: session,
    ),
  };
}
