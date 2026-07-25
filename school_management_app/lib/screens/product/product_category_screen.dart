import 'package:flutter/material.dart';
import 'package:simple_state_management_app/models/product_category.dart';
import 'package:simple_state_management_app/screens/product/product_category_form_screen.dart';
import 'package:simple_state_management_app/services/product_category_service.dart';

class ProductCategoryScreen extends StatefulWidget {
  const ProductCategoryScreen({super.key});

  @override
  State<ProductCategoryScreen> createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  var productCategoryService = ProductCategoryService();
  List<ProductCategory> categoryList = [];
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

    var res = await productCategoryService.getAllCategories();

    setState(() {
      isLoading = false;
      if (res.isSuccess) {
        categoryList = ProductCategory.listFromJson(res.data);
      }
    });
    if (!res.isSuccess && mounted) {
      _showMessage(res.message ?? "Can not load categories", isError: true);
    }
  }

  _onDelete(ProductCategory category) async {
    var res = await productCategoryService.deleteCategory(category.id!);
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
        title:
            Text("Product Categories", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductCategoryFormScreen(),
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
                                ProductCategoryFormScreen(category: category),
                          ),
                        ).then((onValue) {
                          if (onValue == true) {
                            _getAllCategories();
                          }
                        });
                      },
                      leading: Text("${index + 1}", style: TextStyle(fontSize: 18)),
                      title: Text("${category.name}"),
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
