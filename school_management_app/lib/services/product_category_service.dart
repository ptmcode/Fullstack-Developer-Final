import 'package:simple_state_management_app/models/message_res.dart';
import 'package:simple_state_management_app/models/product_category.dart';
import 'package:simple_state_management_app/services/api_client.dart';

class ProductCategoryService {
  Future<MessageRes> getAllCategories() {
    return ApiClient.postMessage("/api/app/product/category/list", auth: true);
  }

  Future<MessageRes> getCategoryById(int id) {
    return ApiClient.postMessage("/api/app/product/category/$id", auth: true);
  }

  Future<MessageRes> createCategory(ProductCategory category) {
    return ApiClient.postMessage("/api/app/product/category/create",
        body: {"name": category.name}, auth: true);
  }

  Future<MessageRes> updateCategory(ProductCategory category) {
    return ApiClient.postMessage("/api/app/product/category/update",
        body: category.toJson(), auth: true);
  }

  Future<MessageRes> deleteCategory(int id) {
    return ApiClient.postMessage("/api/app/product/category/delete",
        body: {"id": id}, auth: true);
  }
}
