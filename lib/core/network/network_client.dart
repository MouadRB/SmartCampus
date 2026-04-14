/// Base URL for every JSONPlaceholder request.
/// Swap this constant to point the whole app at a different API.
const String kBaseUrl = 'https://jsonplaceholder.typicode.com';

/// Hard timeout applied to every outgoing HTTP request.
/// Maps directly to FR-NET-02 (connect/receive timeout requirement).
const Duration kRequestTimeout = Duration(seconds: 10);
