import 'package:flutter/material.dart';
import 'package:simple_state_management_app/models/product.dart';
import 'package:simple_state_management_app/screens/product/product_form_screen.dart';
import 'package:simple_state_management_app/services/product_service.dart';

import '../../widgets/product_card.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  var productService = ProductService();
  List<Product> productList = [];
  bool isLoading = false;

  @override
  void initState() {
    _getAllProducts();
    super.initState();
  }

  _getAllProducts() async {
    setState(() {
      isLoading = true;
      productList = [];
    });

    var res = await productService.getAllProducts();

    setState(() {
      isLoading = false;
      if (res.isSuccess) {
        productList = Product.listFromJson(res.data);
      }
    });
    if (!res.isSuccess && mounted) {
      _showMessage(res.message ?? "Can not load products", isError: true);
    }
  }

  _onDelete(Product product) async {
    var res = await productService.deleteProduct(product.id!);
    if (!mounted) return;
    if (res.isSuccess) {
      _showMessage(res.message ?? "Product deleted successfully!");
      _getAllProducts();
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
        title: Text("List Product", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductFormScreen()),
              ).then((onValue) {
                if (onValue == true) {
                  _getAllProducts();
                }
              });
            },
            icon: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.cyan))
            : RefreshIndicator(
                onRefresh: () async {
                  _getAllProducts();
                },
                child: ListView.builder(
                  itemCount: productList.length,
                  itemBuilder: (context, index) {
                    var product = productList[index];
                    return ProductCard(
                      product: product,
                      index: index,
                      onClickCard: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductFormScreen(
                              product: product,
                            ),
                          ),
                        ).then((onValue) {
                          if (onValue == true) {
                            _getAllProducts();
                          }
                        });
                      },
                      onClickDelete: () {
                        _onDelete(product);
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}
