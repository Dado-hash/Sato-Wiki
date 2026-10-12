import 'dart:async';
import 'dart:io';

/// Runs [read] and force-closes [client] if the whole exchange, including
/// reading the response body, takes longer than [deadline].
///
/// `connectionTimeout` alone does not cover a server that accepts the
/// connection and then stops responding.
Future<T> readWithDeadline<T>({
  required HttpClient client,
  required Duration deadline,
  required Future<T> Function() read,
}) async {
  try {
    return await read().timeout(
      deadline,
      onTimeout: () {
        client.close(force: true);
        throw TimeoutException('Content request timed out.', deadline);
      },
    );
  } finally {
    client.close(force: true);
  }
}
