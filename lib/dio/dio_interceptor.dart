import 'package:dio/dio.dart';
import 'package:dio_playground/dio/dio_client.dart';

class DioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1. Add userId to private endpoints
    // Suppose the path contains open is public
    // If it doesn't we will assume that we want to access the private endpoint
    // For that we are going to append the userId
    if (!options.path.contains('open')) {
      options.queryParameters['userId'] = 'xxx';
    }

    // 2. Validate the user and append the token before the request is sent
    // token can be obtained from shared preference
    options.headers['token'] = 'xxx';

    // 3. Requesting a refresh token before the request is handled by our server
    if (options.headers['refreshToken'] == null) {
      // Lock our current dio instance
      DioClient.dio.lock();
      // create a new dio instance
      Dio _tokenDio = Dio();
      // user this new instance to request a new token
      _tokenDio.get('/token').then((d) {
        options.headers['refreshToken'] = d.data['data']['token'];
        handler.next(options);
      }).catchError((error, stackTrace) {
        handler.reject(error, true);
      }).whenComplete(() {
        DioClient.dio.unlock();
      });
    }

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 200) {
      //do something here
    } else {
      // do otherthing here. Probably reject the request or show some message
    }

    if (response.requestOptions.baseUrl.contains('secret')) {
      // also reject the response and show some message.
    }

    // forward the response to the client
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // catch the error and show a message accordingly
    switch (err.type) {
      case DioErrorType.connectTimeout:
        {}
        break;
      case DioErrorType.receiveTimeout:
        {}
        break;
      case DioErrorType.sendTimeout:
        {}
        break;
      case DioErrorType.cancel:
        {}
        break;
      case DioErrorType.response:
        {}
        break;
      case DioErrorType.other:
        {}
        break;
    }
    // forward the error to the client
    return super.onError(err, handler);
  }
}
