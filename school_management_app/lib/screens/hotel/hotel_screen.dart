import 'package:flutter/material.dart';
import 'package:simple_state_management_app/models/hotel.dart';
import 'package:simple_state_management_app/screens/hotel/hotel_form_screen.dart';
import 'package:simple_state_management_app/services/hotel_service.dart';

class HotelScreen extends StatefulWidget {
  const HotelScreen({super.key});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  var hotelService = HotelService();
  List<Hotel> hotelList = [];
  bool isLoading = false;

  @override
  void initState() {
    _getAllHotels();
    super.initState();
  }

  _getAllHotels() async {
    setState(() {
      isLoading = true;
      hotelList = [];
    });

    var res = await hotelService.getHotels();

    setState(() {
      isLoading = false;
      if (res.isSuccess) {
        hotelList = Hotel.listFromJson(res.data);
      }
    });
    if (!res.isSuccess && mounted) {
      _showMessage(res.message ?? "Can not load hotels", isError: true);
    }
  }

  _onDelete(Hotel hotel) async {
    var res = await hotelService.deleteHotel(hotel.id!);
    if (!mounted) return;
    if (res.isSuccess) {
      _showMessage(res.message ?? "Hotel deleted successfully!");
      _getAllHotels();
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
        title: Text("Hotels", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HotelFormScreen()),
              ).then((onValue) {
                if (onValue == true) {
                  _getAllHotels();
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
                _getAllHotels();
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: hotelList.length,
                itemBuilder: (context, index) {
                  var hotel = hotelList[index];
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
                            builder: (context) => HotelFormScreen(hotel: hotel),
                          ),
                        ).then((onValue) {
                          if (onValue == true) {
                            _getAllHotels();
                          }
                        });
                      },
                      leading: hotel.imageUrl == null || hotel.imageUrl!.isEmpty
                          ? Icon(Icons.hotel, color: Colors.cyan)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.network(
                                hotel.imageUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                    Icon(Icons.hotel, color: Colors.cyan),
                              ),
                            ),
                      title: Text("${hotel.name}"),
                      subtitle: Text(
                        "${hotel.categoryHotel?.name ?? ""} • ${hotel.phone ?? ""}",
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          _onDelete(hotel);
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
