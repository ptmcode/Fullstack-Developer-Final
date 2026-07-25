import 'package:flutter/material.dart';
import 'package:simple_state_management_app/models/product.dart';
import 'package:simple_state_management_app/models/product_category.dart';
import 'package:simple_state_management_app/services/product_category_service.dart';
import 'package:simple_state_management_app/services/product_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  var nameController = TextEditingController();
  var productCodeController = TextEditingController();
  var priceController = TextEditingController();
  var costController = TextEditingController();
  var stockQuantityController = TextEditingController();
  var descriptionController = TextEditingController();
  var productService = ProductService();
  var productCategoryService = ProductCategoryService();
  List<ProductCategory> categories = [];
  int? categoryId;
  bool isLoading = false;

  @override
  void initState() {
    var product = widget.product;
    if (product != null) {
      nameController.text = product.name ?? "";
      productCodeController.text = product.productCode ?? "";
      priceController.text = "${product.price ?? ""}";
      costController.text = "${product.cost ?? ""}";
      stockQuantityController.text = "${product.stockQuantity ?? ""}";
      descriptionController.text = product.description ?? "";
      categoryId = product.category?.id;
    }
    _getCategories();
    super.initState();
  }

  _getCategories() async {
    var res = await productCategoryService.getAllCategories();
    if (res.isSuccess) {
      setState(() {
        categories = ProductCategory.listFromJson(res.data);
      });
    }
  }

  _onSave() async {
    setState(() {
      isLoading = true;
    });

    var product = Product(
      id: widget.product?.id,
      name: nameController.text,
      productCode: productCodeController.text,
      category: ProductCategory(id: categoryId),
      price: num.tryParse(priceController.text) ?? 0,
      cost: num.tryParse(costController.text) ?? 0,
      stockQuantity: num.tryParse(stockQuantityController.text) ?? 0,
      description: descriptionController.text,
      status: widget.product?.status ?? "ACT",
    );
    var res = widget.product == null
        ? await productService.createProduct(product)
        : await productService.updateProduct(product);

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
          widget.product == null ? "Create Product" : "Update Product",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hint: Text("Product name")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: productCodeController,
              decoration: InputDecoration(hint: Text("Product code")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hint: Text("Product price")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hint: Text("Product cost")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: stockQuantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hint: Text("Stock quantity")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(hint: Text("Product description")),
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
                          widget.product == null ? "Create" : "Update",
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
