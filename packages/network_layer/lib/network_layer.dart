/// Supported HTTP methods for network requests.
enum HttpMethod { get, post, put, delete }

/// A very small representation of an HTTP request.
class NetworkRequest {
  NetworkRequest({
    required this.path,
    this.method = HttpMethod.get,
  });

  /// Relative path, e.g. `/habits` or `/status`.
  final String path;

  final HttpMethod method;
}

/// A generic network error.
class NetworkException implements Exception {
  NetworkException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'NetworkException(statusCode: $statusCode, message: $message)';
}

/// Minimal abstraction over a network client.
///
/// In a real app this might be backed by `http` or `dio`, but for this
/// example we keep it simple and use a mock implementation.
abstract class NetworkClient {
  /// Returns a JSON-like map for the given request.
  Future<Map<String, Object?>> getJson(NetworkRequest request);

  /// Returns a simple status message (e.g. for a `/status` or `/health` route).
  Future<String> getStatus();
}

/// A mock client that simulates a backend.
///
/// This makes the example work without any real server while still giving
/// all apps a realistic place to plug into.
class MockNetworkClient implements NetworkClient {
  @override
  Future<Map<String, Object?>> getJson(NetworkRequest request) async {
    // Simulate network latency.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (request.path == '/habits') {
      return <String, Object?>{
        'habits': [
          {
            'id': 'run',
            'name': 'Run 5km',
            'description': 'Go for a 5km run or 30 minutes of jogging.',
            'type': 'duration',
            'dailyTarget': 30,
          },
          {
            'id': 'water',
            'name': 'Drink water',
            'description': 'Drink at least 8 glasses (2L) of water.',
            'type': 'count',
            'dailyTarget': 8,
          },
          {
            'id': 'meditate',
            'name': 'Meditate',
            'description': 'Meditate for at least 10 minutes.',
            'type': 'duration',
            'dailyTarget': 10,
          },
        ],
      };
    }

    throw NetworkException('Unknown mock path: ${request.path}');
  }

  @override
  Future<String> getStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return 'Mock API healthy';
  }
}

/// Singleton-style access to the app-wide network client.
///
/// All apps import this and share the same instance, which is a common
/// pattern in monorepo architectures.
class NetworkLayer {
  NetworkLayer._();

  static final NetworkClient client = MockNetworkClient();
}

