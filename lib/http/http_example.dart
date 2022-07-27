import 'dart:convert';
import 'dart:io';

import 'package:dio_playground/http/post_client.dart';
import 'package:dio_playground/model/post.dart';
import 'package:flutter/material.dart';

class HttpExample extends StatefulWidget {
  const HttpExample({Key? key}) : super(key: key);

  @override
  State<HttpExample> createState() => _HttpExampleState();
}

class _HttpExampleState extends State<HttpExample> {
  var requesting = false;
  late PostClient postClient;
  late Future<Post> post;
  late Future<List<Post>> posts;

  @override
  void initState() {
    super.initState();
    postClient = PostClient();
  }

  request() async {
    try {
      HttpClient httpClient = HttpClient();
      HttpClientRequest request = await httpClient
          .getUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
      request.headers.add('token', 'secureTokenString');
      HttpClientResponse response = await request.close();
      var text = await response.transform(utf8.decoder).join();
      httpClient.close();
      debugPrint(text);
    } catch (e) {
      debugPrint('Request Fail: $e');
    }
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
                      post = postClient.fetchPost(1);
                      setState(() {
                        requesting = true;
                      });
                    },
                    child: const Text('Get Post')),
                ElevatedButton(
                  onPressed: () {
                    posts = postClient.fetchPosts();
                    setState(() {
                      requesting = true;
                    });
                  },
                  child: const Text('Get Post List'),
                ),
                ElevatedButton(
                  onPressed: () {
                    post = postClient.createPost(1, 'test title', 'test body');
                    setState(() {
                      requesting = true;
                    });
                  },
                  child: const Text('Create Post'),
                ),
                ElevatedButton(
                  onPressed: () {
                    post = postClient.updatePost(
                        1, 1, 'updated title', 'updated body');
                    setState(() {
                      requesting = true;
                    });
                  },
                  child: const Text('Update Post'),
                ),
                ElevatedButton(
                  onPressed: () {
                    postClient.deletePost(1);
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
