import 'package:dio/dio.dart';
import 'package:dio_playground/dio/dio_client.dart';
import 'package:dio_playground/dio/dio_token_manager.dart';
import 'package:dio_playground/dio/login_screen.dart';
import 'package:flutter/material.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Welcome Home!'),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              // try {
              //   var response =
              //       await DioClient.dio.get('http://localhost:3000/logout');
              //   if (response.statusCode == 200) {
              //     debugPrint('Message from server: ${response.data}');
              //     Navigator.of(context).pop();
              //   }
              // } on DioError catch (e) {
              //   debugPrint("Error: ${e.response?.data}");
              // }
              TokenManager.instance.clearToken();
              Navigator.of(context).pop();
            },
            child: const Text('Logout'),
          ),
        ]),
      ),
    );
  }
}
