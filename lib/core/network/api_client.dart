import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;
  final Future<String?> Function()? tokenProvider;

  ApiClient({required this.dio, this.tokenProvider}) {
    if (tokenProvider != null) {
      dio.interceptors.add(
        QueuedInterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await tokenProvider!();

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }

            handler.next(options);
          },
        ),
      );
    }
  }
}
