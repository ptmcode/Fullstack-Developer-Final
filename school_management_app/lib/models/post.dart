import 'package:simple_state_management_app/models/post_category.dart';

class Post {
  int? id;
  String? title;
  String? description;
  String? body;
  String? image;
  String? status;
  int? views;
  List<String> tags;
  int likes;
  int dislikes;
  PostCategory? postCategory;

  Post({
    this.id,
    this.title,
    this.description,
    this.body,
    this.image,
    this.status,
    this.views,
    this.tags = const [],
    this.likes = 0,
    this.dislikes = 0,
    this.postCategory,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      body: json["body"],
      image: json["image"],
      status: json["status"],
      views: json["views"],
      tags: (json["tags"] as List? ?? []).map((tag) => "$tag").toList(),
      likes: json["reactions"]?["likes"] ?? 0,
      dislikes: json["reactions"]?["dislikes"] ?? 0,
      postCategory: json["postCategory"] == null
          ? null
          : PostCategory.fromJson(json["postCategory"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "body": body,
      "image": image,
      "categoryId": postCategory?.id,
      "tags": tags,
    };
  }

  static List<Post> listFromJson(dynamic data) {
    return (data as List? ?? []).map((item) => Post.fromJson(item)).toList();
  }
}
