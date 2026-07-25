import 'package:simple_state_management_app/models/product_category.dart';

class Product {
  int? id;
  String? name;
  String? productCode;
  ProductCategory? category;
  num? price;
  num? cost;
  num? stockQuantity;
  String? description;
  String? status;

  Product({
    this.id,
    this.name,
    this.productCode,
    this.category,
    this.price,
    this.cost,
    this.stockQuantity,
    this.description,
    this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      name: json["name"],
      productCode: json["productCode"],
      category: json["category"] == null
          ? null
          : ProductCategory.fromJson(json["category"]),
      price: json["price"],
      cost: json["cost"],
      stockQuantity: json["stockQuantity"],
      description: json["description"],
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "productCode": productCode,
      "category": {"id": category?.id},
      "price": price,
      "cost": cost,
      "stockQuantity": stockQuantity,
      "description": description,
      "status": status,
    };
  }

  static List<Product> listFromJson(dynamic data) {
    return (data as List? ?? []).map((item) => Product.fromJson(item)).toList();
  }
}
