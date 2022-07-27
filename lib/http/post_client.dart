import 'dart:convert';

import 'package:dio_playground/model/post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostClient {
  static const baseUrl = "http://jsonplaceholder.typicode.com";
  static const postsEndpoint = "$baseUrl/posts";

  Future<Post> fetchPost(int postId) async {
    final url = Uri.parse("$postsEndpoint/$postId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      debugPrint(response.body);
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load post: $postId");
    }
  }

  Future<List<Post>> fetchPosts() async {
    final url = Uri.parse(postsEndpoint);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Post.listFromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load posts");
    }
  }

  Future<Post> createPost(
    int userId,
    String title,
    String body,
  ) async {
    final url = Uri.parse(postsEndpoint);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'userId': userId,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 201) {
      debugPrint(response.body);
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create post");
    }
  }

  Future<Post> updatePost(
      int postId, int userId, String title, String body) async {
    final url = Uri.parse("$postsEndpoint/$postId");
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'userId': userId,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint(response.body);
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update post");
    }
  }

  Future<void> deletePost(int postId) async {
    final url = Uri.parse("$postsEndpoint/$postId");
    final response = await http.delete(url, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      debugPrint('Delete Success');
    } else {
      throw Exception("Failed to delete post: $postId");
    }
  }
}
