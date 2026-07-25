class PostCategory {
  int? id;
  String? name;
  String? imageUrl;
  String? status;

  PostCategory({this.id, this.name, this.imageUrl, this.status});

  factory PostCategory.fromJson(Map<String, dynamic> json) {
    return PostCategory(
      id: json["id"],
      name: json["name"],
      imageUrl: json["imageUrl"],
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "imageUrl": imageUrl, "status": status};
  }

  static List<PostCategory> listFromJson(dynamic data) {
    return (data as List? ?? [])
        .map((item) => PostCategory.fromJson(item))
        .toList();
  }
}
