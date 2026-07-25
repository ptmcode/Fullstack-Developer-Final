import 'package:flutter/material.dart';
import 'package:simple_state_management_app/models/post_category.dart';
import 'package:simple_state_management_app/services/post_category_service.dart';

class PostCategoryFormScreen extends StatefulWidget {
  final PostCategory? category;
  const PostCategoryFormScreen({super.key, this.category});

  @override
  State<PostCategoryFormScreen> createState() => _PostCategoryFormScreenState();
}

class _PostCategoryFormScreenState extends State<PostCategoryFormScreen> {
  var nameController = TextEditingController();
  var imageUrlController = TextEditingController();
  var postCategoryService = PostCategoryService();
  bool isLoading = false;

  @override
  void initState() {
    if (widget.category != null) {
      nameController.text = widget.category!.name ?? "";
      imageUrlController.text = widget.category!.imageUrl ?? "";
    }
    super.initState();
  }

  _onSave() async {
    setState(() {
      isLoading = true;
    });

    var category = PostCategory(
      id: widget.category?.id,
      name: nameController.text,
      imageUrl: imageUrlController.text,
      status: widget.category?.status ?? "ACT",
    );
    var res = widget.category == null
        ? await postCategoryService.createCategory(category)
        : await postCategoryService.updateCategory(category);

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
          widget.category == null ? "Create Category" : "Update Category",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 35),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hint: Text("Category name")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(hint: Text("Image URL")),
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
                          widget.category == null ? "Create" : "Update",
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
