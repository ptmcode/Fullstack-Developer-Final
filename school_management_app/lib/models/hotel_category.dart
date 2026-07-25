class HotelCategory {
  int? id;
  String? name;
  String? status;

  HotelCategory({this.id, this.name, this.status});

  factory HotelCategory.fromJson(Map<String, dynamic> json) {
    return HotelCategory(
      id: json["id"],
      name: json["name"],
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "status": status};
  }

  static List<HotelCategory> listFromJson(dynamic data) {
    return (data as List? ?? [])
        .map((item) => HotelCategory.fromJson(item))
        .toList();
  }
}
