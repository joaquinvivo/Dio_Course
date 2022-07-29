import 'package:dio/dio.dart';
import 'package:dio_playground/dio/dio_client.dart';
import 'package:dio_playground/dio/dio_token_manager.dart';
// import 'package:dio_playground/dio/dio_cookie_manager.dart';
import 'package:dio_playground/dio/logout_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllerUsername = TextEditingController();
  final _controllerPassword = TextEditingController();
  var _username = '', _password = '';

  @override
  void initState() {
    super.initState();
    () async {
      //   String appDocPath = await getDocPath();
      //   var persistCookieJar = PersistCookieJar(
      //       ignoreExpires: true, storage: FileStorage("$appDocPath/cookies/"));
      //   DioClient.dio.interceptors.add(CookieManager(persistCookieJar));
      // DioClient.dio.interceptors.add(CookieManager.instance); // The manual way

      DioClient.dio.interceptors.add(TokenManager.instance);
      await checkLogin();
    }();
  }

  // Future<String> getDocPath() async {
  //   var appDocDir = await getApplicationDocumentsDirectory();
  //   return appDocDir.path;
  // }

  Future<void> checkLogin() async {
    try {
      var response = await DioClient.dio.get('http://localhost:3000/');
      if (response.statusCode == 200) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const LogoutScreen()));
      }
    } on DioError catch (e) {
      debugPrint("Status code: ${e.response?.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (val) => val!.isEmpty ? 'Username Required' : null,
                onSaved: (val) => _username = val!,
                keyboardType: TextInputType.text,
                controller: _controllerUsername,
                autocorrect: false,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (val) => val!.isEmpty ? 'Password Required' : null,
                onSaved: (val) => _password = val!,
                keyboardType: TextInputType.text,
                controller: _controllerPassword,
                obscureText: true,
                autocorrect: false,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final form = _formKey.currentState;
                  if (form!.validate()) {
                    form.save();
                    final snackbar = SnackBar(
                      duration: const Duration(seconds: 30),
                      content: Row(
                        children: const [
                          CircularProgressIndicator(),
                          Text('  Logging in...'),
                        ],
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    await Future.delayed(const Duration(seconds: 2));
                    try {
                      var response = await DioClient.dio.post(
                        'http://localhost:3000/login',
                        data: {
                          'userName': _username,
                          'password': _password,
                        },
                      );
                      if (response.statusCode == 200) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const LogoutScreen()));
                      }
                    } on DioError catch (e) {
                      debugPrint("Error: ${e.response?.data}");
                    }
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  }
                },
                child: const Text('Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
