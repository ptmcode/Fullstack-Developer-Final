class ProductCategory {
  int? id;
  String? name;

  ProductCategory({this.id, this.name});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(id: json["id"], name: json["name"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name};
  }

  static List<ProductCategory> listFromJson(dynamic data) {
    return (data as List? ?? [])
        .map((item) => ProductCategory.fromJson(item))
        .toList();
  }
}
