import 'package:flutter/material.dart';
import 'package:simple_state_management_app/models/hotel_category.dart';
import 'package:simple_state_management_app/services/hotel_service.dart';

class HotelCategoryFormScreen extends StatefulWidget {
  final HotelCategory? category;
  const HotelCategoryFormScreen({super.key, this.category});

  @override
  State<HotelCategoryFormScreen> createState() =>
      _HotelCategoryFormScreenState();
}

class _HotelCategoryFormScreenState extends State<HotelCategoryFormScreen> {
  var nameController = TextEditingController();
  var hotelService = HotelService();
  bool isLoading = false;

  @override
  void initState() {
    if (widget.category != null) {
      nameController.text = widget.category!.name ?? "";
    }
    super.initState();
  }

  _onSave() async {
    setState(() {
      isLoading = true;
    });

    var category = HotelCategory(
      id: widget.category?.id,
      name: nameController.text,
      status: widget.category?.status ?? "ACT",
    );
    var res = widget.category == null
        ? await hotelService.createCategory(category)
        : await hotelService.updateCategory(category);

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
