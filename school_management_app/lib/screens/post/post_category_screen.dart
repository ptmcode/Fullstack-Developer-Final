import 'package:flutter/material.dart';
import 'package:simple_state_management_app/models/post_category.dart';
import 'package:simple_state_management_app/screens/post/post_category_form_screen.dart';
import 'package:simple_state_management_app/services/post_category_service.dart';

class PostCategoryScreen extends StatefulWidget {
  const PostCategoryScreen({super.key});

  @override
  State<PostCategoryScreen> createState() => _PostCategoryScreenState();
}

class _PostCategoryScreenState extends State<PostCategoryScreen> {
  var postCategoryService = PostCategoryService();
  List<PostCategory> categoryList = [];
  bool isLoading = false;

  @override
  void initState() {
    _getAllCategories();
    super.initState();
  }

  _getAllCategories() async {
    setState(() {
      isLoading = true;
      categoryList = [];
    });

    var res = await postCategoryService.getCategories();

    setState(() {
      isLoading = false;
      if (res.isSuccess) {
        categoryList = PostCategory.listFromJson(res.data);
      }
    });
    if (!res.isSuccess && mounted) {
      _showMessage(res.message ?? "Can not load categories", isError: true);
    }
  }

  _onDelete(PostCategory category) async {
    var res = await postCategoryService.deleteCategory(category.id!);
    if (!mounted) return;
    if (res.isSuccess) {
      _showMessage(res.message ?? "Category deleted successfully!");
      _getAllCategories();
    } else {
      _showMessage(res.message ?? "Delete failed", isError: true);
    }
  }

  _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Post Categories", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostCategoryFormScreen(),
                ),
              ).then((onValue) {
                if (onValue == true) {
                  _getAllCategories();
                }
              });
            },
            icon: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.cyan))
          : RefreshIndicator(
              onRefresh: () async {
                _getAllCategories();
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  var category = categoryList[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostCategoryFormScreen(category: category),
                          ),
                        ).then((onValue) {
                          if (onValue == true) {
                            _getAllCategories();
                          }
                        });
                      },
                      leading: Text("${index + 1}", style: TextStyle(fontSize: 18)),
                      title: Text("${category.name}"),
                      subtitle: Text("Status: ${category.status}"),
                      trailing: IconButton(
                        onPressed: () {
                          _onDelete(category);
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
