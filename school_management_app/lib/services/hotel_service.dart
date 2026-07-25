import 'package:simple_state_management_app/models/hotel.dart';
import 'package:simple_state_management_app/models/hotel_category.dart';
import 'package:simple_state_management_app/models/message_res.dart';
import 'package:simple_state_management_app/services/api_client.dart';

class HotelService {
  // Public endpoints
  Future<MessageRes> getPublicHotels({String type = "ALL", int? categoryHotelId}) {
    var body = <String, dynamic>{"type": type};
    if (categoryHotelId != null) body["categoryHotelId"] = categoryHotelId;
    return ApiClient.postMessage("/api/public/hotels/list", body: body);
  }

  Future<MessageRes> getPublicHotelById(int id) {
    return ApiClient.postMessage("/api/public/hotels/getById/$id");
  }

  Future<MessageRes> getPublicCategories() {
    return ApiClient.postMessage("/api/public/hotels/category/list");
  }

  // Admin endpoints
  Future<MessageRes> getHotels() {
    return ApiClient.postMessage("/api/app/admin/hotel/list", auth: true);
  }

  Future<MessageRes> getHotelById(int id) {
    return ApiClient.postMessage("/api/app/admin/hotel/$id", auth: true);
  }

  Future<MessageRes> createHotel(Hotel hotel) {
    return ApiClient.postMessage("/api/app/admin/hotel/create",
        body: hotel.toJson(), auth: true);
  }

  Future<MessageRes> updateHotel(Hotel hotel) {
    return ApiClient.postMessage("/api/app/admin/hotel/update",
        body: hotel.toJson(), auth: true);
  }

  Future<MessageRes> deleteHotel(int id) {
    return ApiClient.postMessage("/api/app/admin/hotel/delete",
        body: {"id": id}, auth: true);
  }

  Future<MessageRes> getCategories() {
    return ApiClient.postMessage("/api/app/admin/hotel/category/list",
        auth: true);
  }

  Future<MessageRes> getCategoryById(int id) {
    return ApiClient.postMessage("/api/app/admin/hotel/category/$id",
        auth: true);
  }

  Future<MessageRes> createCategory(HotelCategory category) {
    return ApiClient.postMessage("/api/app/admin/hotel/category/create",
        body: {"name": category.name, "status": category.status}, auth: true);
  }

  Future<MessageRes> updateCategory(HotelCategory category) {
    return ApiClient.postMessage("/api/app/admin/hotel/category/update",
        body: category.toJson(), auth: true);
  }

  Future<MessageRes> deleteCategory(int id) {
    return ApiClient.postMessage("/api/app/admin/hotel/category/delete",
        body: {"id": id}, auth: true);
  }
}
