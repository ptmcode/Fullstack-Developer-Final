import 'package:simple_state_management_app/models/message_res.dart';
import 'package:simple_state_management_app/models/post.dart';
import 'package:simple_state_management_app/services/api_client.dart';

class PostService {
  String _listQuery(int page, int size, String status, int? categoryId,
      int? userId, String? keyword) {
    var query = "page=$page&size=$size&status=$status";
    if (categoryId != null) query += "&categoryId=$categoryId";
    if (userId != null) query += "&userId=$userId";
    if (keyword != null && keyword.isNotEmpty) query += "&keyword=$keyword";
    return query;
  }

  Future<MessageRes> getPublicPosts(
      {int page = 0,
      int size = 10,
      String status = "ACT",
      int? categoryId,
      int? userId,
      String? keyword}) {
    return ApiClient.getMessage(
        "/api/public/post?${_listQuery(page, size, status, categoryId, userId, keyword)}");
  }

  Future<MessageRes> getPosts(
      {int page = 0,
      int size = 10,
      String status = "ACT",
      int? categoryId,
      int? userId,
      String? keyword}) {
    return ApiClient.getMessage(
        "/api/app/post?${_listQuery(page, size, status, categoryId, userId, keyword)}",
        auth: true);
  }

  Future<MessageRes> getPublicPostById(int id) {
    return ApiClient.getMessage("/api/public/post/$id");
  }

  Future<MessageRes> getPostById(int id) {
    return ApiClient.getMessage("/api/app/post/$id", auth: true);
  }

  Future<MessageRes> likePost(int id) {
    return ApiClient.postMessage("/api/public/post/$id/like");
  }

  Future<MessageRes> dislikePost(int id) {
    return ApiClient.postMessage("/api/public/post/$id/dislike");
  }

  Future<MessageRes> createPost(Post post) {
    return ApiClient.postMessage("/api/app/post", body: post.toJson(), auth: true);
  }

  Future<MessageRes> updatePost(Post post) {
    return ApiClient.putMessage("/api/app/post/${post.id}",
        body: post.toJson(), auth: true);
  }

  Future<MessageRes> deletePost(int id) {
    return ApiClient.deleteMessage("/api/app/post/$id", auth: true);
  }
}
