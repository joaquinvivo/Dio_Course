import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CookieManager extends Interceptor {
  // 1. Singleton Factory constructor
  // static final CookieManager _instance = CookieManager._internal();
  // factory CookieManager() => _instance;
  // CookieManager._internal();
  // CookieManager manager = CookieManager();

  // 2. Singleton Static field with getter
  static final CookieManager _instance = CookieManager._internal();
  static CookieManager get instance => _instance;
  CookieManager._internal();
  // CookieManager manager = CookieManager.instance;

  String? _cookie;

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (response.statusCode == 200) {
      if (response.headers.map['set-cookie'] != null) {
        _saveCookie(response.headers.map['set-cookie']![0]);
      }
    } else if (response.statusCode == 401) {
      _clearCookie();
    }
    super.onResponse(response, handler);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    debugPrint('current cookie: $_cookie');
    options.headers['Cookie'] = _cookie;
    return super.onRequest(options, handler);
  }

  Future<void> initCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _cookie = prefs.getString('cookie');
  }

  void _saveCookie(String newCookie) async {
    if (_cookie != newCookie) {
      _cookie = newCookie;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('cookie', _cookie!);
    }
  }

  void _clearCookie() async {
    _cookie = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('cookie');
  }
}
