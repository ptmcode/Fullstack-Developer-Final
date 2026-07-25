import 'package:simple_state_management_app/models/hotel_category.dart';

class Hotel {
  int? id;
  int? userId;
  String? name;
  String? description;
  String? imageUrl;
  String? phone;
  String? email;
  String? status;
  HotelCategory? categoryHotel;

  Hotel({
    this.id,
    this.userId,
    this.name,
    this.description,
    this.imageUrl,
    this.phone,
    this.email,
    this.status,
    this.categoryHotel,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json["id"],
      userId: json["userId"],
      name: json["name"],
      // The API response serializes this field as "decription".
      description: json["description"] ?? json["decription"],
      imageUrl: json["imageUrl"],
      phone: json["phone"],
      email: json["email"],
      status: json["status"],
      categoryHotel: json["categoryHotel"] == null
          ? null
          : HotelCategory.fromJson(json["categoryHotel"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "name": name,
      "description": description,
      "imageUrl": imageUrl,
      "phone": phone,
      "email": email,
      "categoryHotelId": categoryHotel?.id,
    };
  }

  static List<Hotel> listFromJson(dynamic data) {
    return (data as List? ?? []).map((item) => Hotel.fromJson(item)).toList();
  }
}
