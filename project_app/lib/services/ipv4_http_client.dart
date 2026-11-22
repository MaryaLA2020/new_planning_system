import 'package:http/http.dart' as http;

import 'ipv4_http_client_stub.dart'
    if (dart.library.io) 'ipv4_http_client_io.dart';

/// Создает HTTP-клиент: на Mobile/Desktop принудительно использует IPv4,
/// в Web возвращает стандартный браузерный клиент.
http.Client createFastHttpClient() => getPlatformHttpClient();
