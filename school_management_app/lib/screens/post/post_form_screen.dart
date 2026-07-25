import 'package:flutter/material.dart';
import 'package:simple_state_management_app/models/post.dart';
import 'package:simple_state_management_app/models/post_category.dart';
import 'package:simple_state_management_app/services/post_category_service.dart';
import 'package:simple_state_management_app/services/post_service.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post;
  const PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var bodyController = TextEditingController();
  var imageController = TextEditingController();
  var tagsController = TextEditingController();
  var postService = PostService();
  var postCategoryService = PostCategoryService();
  List<PostCategory> categories = [];
  int? categoryId;
  bool isLoading = false;

  @override
  void initState() {
    var post = widget.post;
    if (post != null) {
      titleController.text = post.title ?? "";
      descriptionController.text = post.description ?? "";
      bodyController.text = post.body ?? "";
      imageController.text = post.image ?? "";
      tagsController.text = post.tags.join(", ");
      categoryId = post.postCategory?.id;
    }
    _getCategories();
    super.initState();
  }

  _getCategories() async {
    var res = await postCategoryService.getCategories();
    if (res.isSuccess) {
      setState(() {
        categories = PostCategory.listFromJson(res.data);
      });
    }
  }

  _onSave() async {
    setState(() {
      isLoading = true;
    });

    var post = Post(
      id: widget.post?.id,
      title: titleController.text,
      description: descriptionController.text,
      body: bodyController.text,
      image: imageController.text,
      tags: tagsController.text
          .split(",")
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList(),
      postCategory: PostCategory(id: categoryId),
    );
    var res = widget.post == null
        ? await postService.createPost(post)
        : await postService.updatePost(post);

    setState(() {
      isLoading = false;
    });
    if (!mounted) return;

    if (res.isSuccess) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? "Save failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.post == null ? "Create Post" : "Update Post",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 35),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(hint: Text("Title")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(hint: Text("Description")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: bodyController,
              maxLines: 5,
              decoration: InputDecoration(hint: Text("Body")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: imageController,
              decoration: InputDecoration(hint: Text("Image URL")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: tagsController,
              decoration:
                  InputDecoration(hint: Text("Tags (separated by comma)")),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<int>(
              initialValue: categoryId,
              hint: Text("Category"),
              items: [
                for (var category in categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text("${category.name}"),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  categoryId = value;
                });
              },
            ),
            GestureDetector(
              onTap: () {
                if (!isLoading) {
                  _onSave();
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 35),
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.post == null ? "Create" : "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
