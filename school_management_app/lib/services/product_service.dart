import 'package:simple_state_management_app/models/message_res.dart';
import 'package:simple_state_management_app/models/product.dart';
import 'package:simple_state_management_app/services/api_client.dart';

class ProductService {
  Future<MessageRes> getAllProducts({String status = "ALL"}) {
    return ApiClient.postMessage("/api/app/product/list",
        body: {"status": status}, auth: true);
  }

  Future<MessageRes> getProductById(int id) {
    return ApiClient.postMessage("/api/app/product/$id", auth: true);
  }

  Future<MessageRes> createProduct(Product product) {
    var body = product.toJson();
    body.remove("id");
    return ApiClient.postMessage("/api/app/product/create",
        body: body, auth: true);
  }

  Future<MessageRes> updateProduct(Product product) {
    return ApiClient.postMessage("/api/app/product/update",
        body: product.toJson(), auth: true);
  }

  Future<MessageRes> deleteProduct(int id) {
    return ApiClient.postMessage("/api/app/product/delete",
        body: {"id": id}, auth: true);
  }
}
