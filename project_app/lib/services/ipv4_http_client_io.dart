import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client getPlatformHttpClient() {
  final ioClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10)
    ..findProxy = HttpClient.findProxyFromEnvironment;

  // Переопределяем DNS-поиск: берем только быстрые IPv4-адреса
  ioClient.connectionFactory = (Uri uri, String? proxyHost, int? proxyPort) async {
    final addresses = await InternetAddress.lookup(
      uri.host,
      type: InternetAddressType.IPv4,
    );
    return Socket.startConnect(addresses.first, uri.port);
  };

  return IOClient(ioClient);
}
