import 'package:dio/dio.dart';
import 'package:dio_playground/model/post.dart';
import 'package:flutter/material.dart';

class DioClient {
  static Dio dio = Dio();
  static const baseUrl = "http://jsonplaceholder.typicode.com";
  static const postsEndpoint = "$baseUrl/posts";

  Future<Post> fetchPost(int postId) async {
    // https://jsonplaceholder.typicode.com/posts/1
    try {
      final response = await dio.get("$postsEndpoint/$postId");
      // https://jsonplaceholder.typicode.com/posts?id=1
      // final response = await dio.get(postsEndpoint, queryParameters: {'id': postId});

      debugPrint(response.toString());
      return Post.fromJson(response.data);
    } on DioError catch (e) {
      debugPrint('Status code: ${e.response?.statusCode.toString()}');
      throw Exception('Failed to load post: $postId');
    }
  }

  Future<List<Post>> fetchPosts() async {
    try {
      final response = await dio.get(postsEndpoint);
      return Post.listFromJson(response.data);
    } on DioError catch (e) {
      debugPrint('Status code: ${e.response?.statusCode.toString()}');
      throw Exception('Failed to load posts');
    }
  }

  Future<Post> createPost(int userId, String title, String body) async {
    try {
      final response = await dio.post(
        postsEndpoint,
        data: {
          'userId': userId,
          'title': title,
          'body': body,
        },
      );
      debugPrint(response.toString());
      return Post.fromJson(response.data);
    } on DioError catch (e) {
      debugPrint('Status code: ${e.response?.statusCode.toString()}');
      throw Exception('Failed to create post');
    }
  }

  Future<Post> updatePost(
      int postId, int userId, String title, String body) async {
    try {
      final response = await dio.put(
        "$postsEndpoint/$postId",
        data: {
          'userId': userId,
          'title': title,
          'body': body,
        },
      );
      debugPrint(response.toString());
      return Post.fromJson(response.data);
    } on DioError catch (e) {
      debugPrint('Status code: ${e.response?.statusCode.toString()}');
      throw Exception('Failed to update post');
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      await dio.delete("$postsEndpoint/$postId");
      debugPrint('Delete Success');
    } on DioError catch (e) {
      debugPrint('Status code: ${e.response?.statusCode.toString()}');
      throw Exception('Failed to delete post: $postId');
    }
  }
}
