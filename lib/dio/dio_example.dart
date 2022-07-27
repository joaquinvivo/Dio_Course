import 'package:dio/dio.dart';
import 'package:dio_playground/dio/dio_client.dart';
import 'package:dio_playground/dio/dio_interceptor.dart';
import 'package:dio_playground/model/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class DioExample extends StatefulWidget {
  const DioExample({Key? key}) : super(key: key);

  @override
  State<DioExample> createState() => _DioExampleState();
}

class _DioExampleState extends State<DioExample> {
  var requesting = false;
  late DioClient dioClient;
  late Future<Post> post;
  late Future<List<Post>> posts;

  @override
  void initState() {
    super.initState();
    dioClient = DioClient();
    DioClient.dio.interceptors.add(DioInterceptor());

    //If you want to resolve the request with some custom data, you can resolve
    // a 'Response' object eg: 'handler.resolve(response)'.
    //If you want to reject the request with an error message, you can reject
    // a 'DioError' object eg: 'handler.reject(error)'.
    DioClient.dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) {
      // Do something before request is sent
      return handler.next(options);
      // return handler.resolve(Response(requestOptions: options, data: 'fake data));
    }, onResponse: (response, handler) {
      // Do something with response data
      return handler.next(response);
    }, onError: (DioError e, handler) {
      // Do something with response error
      return handler.next(e);
    }));
    // you can also add a list of interceptors
    DioClient.dio.interceptors.addAll([]);

    String? refreshToken;
    var tokenDio = Dio();
    DioClient.dio.interceptors
        .add(QueuedInterceptorsWrapper(onRequest: ((options, handler) {
      if (refreshToken == null) {
        tokenDio.get('/token').then((d) {
          options.headers['refreshToken'] =
              refreshToken = d.data['data']['token'];
          handler.next(options);
        });
      } else {
        options.headers['refreshToken'] = refreshToken;
        handler.next(options);
      }
    }), onError: (error, handler) {
      // Assume 401 stands for token expired
      if (error.response?.statusCode == 401) {
        var options = error.response!.requestOptions;
        tokenDio.get('/token').then((d) {
          //update refreshToken
          options.headers['refreshToken'] = d.data['data']['token'];
        }).then((e) {
          //repeat
          DioClient.dio.fetch(options).then(
            (r) => handler.resolve(r),
            onError: (e) {
              handler.reject(e);
            },
          );
        });
        return;
      }
      return handler.next(error);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (requesting)
            FutureBuilder<Post>(
                future: post,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text('Title -> ${snapshot.data!.title}'),
                            Text('Body -> ${snapshot.data!.body}'),
                          ],
                        ));
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
          // FutureBuilder<List<Post>>(
          //   future: posts,
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       return Padding(
          //           padding: const EdgeInsets.all(24.0),
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text('Title -> ${snapshot.data![0].title}'),
          //               Text('Body -> ${snapshot.data![0].body}'),
          //               const SizedBox(
          //                 height: 24,
          //               ),
          //               Text('Title -> ${snapshot.data![1].title}'),
          //               Text('Body -> ${snapshot.data![1].body}'),
          //             ],
          //           ));
          //     } else if (snapshot.hasError) {
          //       return Text('Error: ${snapshot.error}');
          //     } else {
          //       return const CircularProgressIndicator();
          //     }
          //   },
          // ),
          Center(
            child: Wrap(
              spacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      post = dioClient.fetchPost(1);
                      setState(() {
                        requesting = true;
                      });
                    },
                    child: const Text('Get Post')),
                ElevatedButton(
                  onPressed: () {
                    posts = dioClient.fetchPosts();
                    setState(() {
                      requesting = true;
                    });
                  },
                  child: const Text('Get Post List'),
                ),
                ElevatedButton(
                  onPressed: () {
                    post = dioClient.createPost(1, 'test title', 'test body');
                    setState(() {
                      requesting = true;
                    });
                  },
                  child: const Text('Create Post'),
                ),
                ElevatedButton(
                  onPressed: () {
                    post = dioClient.updatePost(
                      1,
                      1,
                      'updated title',
                      'updated body',
                    );
                    setState(() {
                      requesting = true;
                    });
                  },
                  child: const Text('Update Post'),
                ),
                ElevatedButton(
                  onPressed: () {
                    dioClient.deletePost(1);
                    setState(() {
                      requesting = true;
                    });
                  },
                  child: const Text('Delete Post'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      requesting = false;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
