import 'package:simple_state_management_app/models/message_res.dart';
import 'package:simple_state_management_app/models/post_category.dart';
import 'package:simple_state_management_app/services/api_client.dart';

class PostCategoryService {
  Future<MessageRes> getPublicCategories({String status = "ACT"}) {
    return ApiClient.getMessage("/api/public/post-category?status=$status");
  }

  Future<MessageRes> getPublicCategoryById(int id) {
    return ApiClient.getMessage("/api/public/post-category/$id");
  }

  Future<MessageRes> getCategories({String status = "ACT"}) {
    return ApiClient.getMessage("/api/app/post/category?status=$status",
        auth: true);
  }

  Future<MessageRes> getCategoryById(int id) {
    return ApiClient.getMessage("/api/app/post/category/$id", auth: true);
  }

  Future<MessageRes> createCategory(PostCategory category) {
    return ApiClient.postMessage("/api/app/post/category",
        body: category.toJson(), auth: true);
  }

  Future<MessageRes> updateCategory(PostCategory category) {
    return ApiClient.putMessage("/api/app/post/category/${category.id}",
        body: category.toJson(), auth: true);
  }

  Future<MessageRes> deleteCategory(int id) {
    return ApiClient.deleteMessage("/api/app/post/category/$id", auth: true);
  }
}
