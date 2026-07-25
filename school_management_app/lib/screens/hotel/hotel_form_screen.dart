import 'package:flutter/material.dart';
import 'package:simple_state_management_app/models/hotel.dart';
import 'package:simple_state_management_app/models/hotel_category.dart';
import 'package:simple_state_management_app/services/hotel_service.dart';
import 'package:simple_state_management_app/services/session.dart';

class HotelFormScreen extends StatefulWidget {
  final Hotel? hotel;
  const HotelFormScreen({super.key, this.hotel});

  @override
  State<HotelFormScreen> createState() => _HotelFormScreenState();
}

class _HotelFormScreenState extends State<HotelFormScreen> {
  var nameController = TextEditingController();
  var descriptionController = TextEditingController();
  var imageUrlController = TextEditingController();
  var phoneController = TextEditingController();
  var emailController = TextEditingController();
  var hotelService = HotelService();
  List<HotelCategory> categories = [];
  int? categoryId;
  bool isLoading = false;

  @override
  void initState() {
    var hotel = widget.hotel;
    if (hotel != null) {
      nameController.text = hotel.name ?? "";
      descriptionController.text = hotel.description ?? "";
      imageUrlController.text = hotel.imageUrl ?? "";
      phoneController.text = hotel.phone ?? "";
      emailController.text = hotel.email ?? "";
      categoryId = hotel.categoryHotel?.id;
    }
    _getCategories();
    super.initState();
  }

  _getCategories() async {
    var res = await hotelService.getCategories();
    if (res.isSuccess) {
      setState(() {
        categories = HotelCategory.listFromJson(res.data);
      });
    }
  }

  _onSave() async {
    setState(() {
      isLoading = true;
    });

    var hotel = Hotel(
      id: widget.hotel?.id,
      userId: widget.hotel?.userId ?? Session.currentUser?.id,
      name: nameController.text,
      description: descriptionController.text,
      imageUrl: imageUrlController.text,
      phone: phoneController.text,
      email: emailController.text,
      categoryHotel: HotelCategory(id: categoryId),
    );
    var res = widget.hotel == null
        ? await hotelService.createHotel(hotel)
        : await hotelService.updateHotel(hotel);

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
          widget.hotel == null ? "Create Hotel" : "Update Hotel",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 35),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hint: Text("Hotel name")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(hint: Text("Description")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(hint: Text("Image URL")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(hint: Text("Phone")),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hint: Text("Email")),
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
                          widget.hotel == null ? "Create" : "Update",
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
