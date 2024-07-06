import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'drawer.dart';

class RoomDetails extends StatefulWidget {
  final User adminId;

  const RoomDetails({Key? key, required this.adminId}) : super(key: key);

  @override
  State<RoomDetails> createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetails> {
  List<Map<String, dynamic>> _rooms = [];
  List<TextEditingController> _totalRoomsControllers = [];
  List<TextEditingController> _roomPriceControllers = [];
  List<TextEditingController> _perChildPriceControllers = [];
  List<TextEditingController> _perAdultPriceControllers = [];
  List<TextEditingController> _discountControllers = [];
  List<List<String>> _selectedFacilities = [];
  List<String> _roomTypeValues = [];
  List<String> _bedTypeValues = [];
  List<String> _roomAvailabilityValues = [];
  bool _isLoading = true;
  bool _isUploading = false; // Added for uploading state
  final _selectedRoomType = ['Select Room Type', 'Standard', 'Deluxe', 'Suite'];
  final _selectedBedType = [
    'Select Your Bed Type',
    'Single',
    'Double',
    'Standard'
  ];
  final _selectedAvailability = ['Select room Availability', 'Yes', 'No'];
  final _availableFacilities = [
    'WiFi',
    'TV',
    'Air Conditioning',
    'Mini Bar',
    'Room Service',
    'Laundry',
    'Parking'
  ];

  final _facilityIcons = {
    'WiFi': Icons.wifi,
    'TV': Icons.tv,
    'Air Conditioning': Icons.ac_unit,
    'Mini Bar': Icons.local_bar,
    'Room Service': Icons.room_service,
    'Laundry': Icons.local_laundry_service,
    'Parking': Icons.local_parking,
  };

  @override
  void initState() {
    super.initState();
    _fetchRoomData();
  }

  void _addRoom() {
    setState(() {
      _rooms.add({
        'totalRooms': '',
        'roomType': _selectedRoomType[0], // Default to 'Select Room Type'
        'bedType': _selectedBedType[0], // Default to 'Select Your Bed Type'
        'roomPrice': '',
        'perAdultPrice': '',
        'perChildPrice': '',
        'discount': '',
        'availability':
            _selectedAvailability[0], // Default to 'Select room Availability'
        'facilities': []
      });
      _totalRoomsControllers.add(TextEditingController());
      _roomPriceControllers.add(TextEditingController());
      _perAdultPriceControllers.add(TextEditingController());
      _perChildPriceControllers.add(TextEditingController());
      _discountControllers.add(TextEditingController());
      _roomTypeValues.add(_selectedRoomType[0]);
      _selectedFacilities.add([]);
      _bedTypeValues.add(_selectedBedType[0]);
      _roomAvailabilityValues.add(_selectedAvailability[0]);
    });
  }

  Future<void> _fetchRoomData() async {
    setState(() {
      _isLoading = true; // Set loading state before fetching
    });

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Hotels')
              .doc(widget.adminId.uid)
              .collection('Rooms')
              .get();

      setState(() {
        _rooms.clear();
        _totalRoomsControllers.clear();
        _roomPriceControllers.clear();
        _perAdultPriceControllers.clear();
        _perChildPriceControllers.clear();
        _discountControllers.clear();
        _roomTypeValues.clear();
        _bedTypeValues.clear();
        _roomAvailabilityValues.clear();
        _selectedFacilities.clear();

        for (var doc in snapshot.docs) {
          var room = doc.data();
          room['roomId'] = doc.id;
          _rooms.add(room);
          _totalRoomsControllers
              .add(TextEditingController(text: room['totalRooms'].toString()));
          _roomPriceControllers
              .add(TextEditingController(text: room['roomPrice'].toString()));
          _perAdultPriceControllers.add(TextEditingController(
              text: room['perAdultPrice']?.toString() ?? ''));
          _perChildPriceControllers.add(TextEditingController(
              text: room['perChildPrice']?.toString() ?? ''));
          _discountControllers.add(
              TextEditingController(text: room['discount']?.toString() ?? ''));
          _roomTypeValues
              .add(room['roomType']?.toString() ?? _selectedRoomType[0]);
          _bedTypeValues
              .add(room['bedType']?.toString() ?? _selectedBedType[0]);
          _roomAvailabilityValues.add(
              room['availability']?.toString() ?? _selectedAvailability[0]);
          _selectedFacilities.add(List<String>.from(room['facilities'] ?? []));
        }

        _isLoading = false; // Set loading state after fetching
      });
    } catch (error) {
      print("Error fetching data: $error");
      setState(() {
        _isLoading = false; // Set loading state in case of error
      });
    }
  }

  void _deleteRoom(int index) async {
    final String roomId = _rooms[index]['roomId'];
    setState(() {
      _rooms.removeAt(index);
      _totalRoomsControllers.removeAt(index);
      _roomPriceControllers.removeAt(index);
      _perAdultPriceControllers.removeAt(index);
      _perChildPriceControllers.removeAt(index);
      _discountControllers.removeAt(index);
      _roomTypeValues.removeAt(index);
      _bedTypeValues.removeAt(index);
      _roomAvailabilityValues.removeAt(index);
      _selectedFacilities.removeAt(index);
    });

    try {
      await FirebaseFirestore.instance
          .collection('Hotels')
          .doc(widget.adminId.uid)
          .collection('Rooms')
          .doc(roomId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print("Failed: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete room: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildRoomDetails(int index) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.black54),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                TextField(
                  controller: _totalRoomsControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Total Room',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: DropdownButton<String>(
                    value: _roomTypeValues[index],
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down_outlined,
                        color: Colors.black),
                    items: _selectedRoomType.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (String? newvalue) {
                      setState(() {
                        _roomTypeValues[index] = newvalue!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: DropdownButton<String>(
                    value: _bedTypeValues[index],
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down_outlined,
                        color: Colors.black),
                    items: _selectedBedType.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (String? newvalue) {
                      setState(() {
                        _bedTypeValues[index] = newvalue!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: _selectedFacilities[index].map((facility) {
                    return Chip(
                      avatar: Icon(_facilityIcons[facility]),
                      label: Text(facility),
                      onDeleted: () {
                        setState(() {
                          _selectedFacilities[index].remove(facility);
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  hint: Text('Select Facility'),
                  items: _availableFacilities.map((String facility) {
                    return DropdownMenuItem<String>(
                      value: facility,
                      child: Row(
                        children: [
                          Icon(_facilityIcons[facility]),
                          SizedBox(width: 8),
                          Text(facility),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? selectedFacility) {
                    if (selectedFacility != null &&
                        !_selectedFacilities[index]
                            .contains(selectedFacility)) {
                      setState(() {
                        _selectedFacilities[index].add(selectedFacility);
                      });
                    }
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _roomPriceControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Room Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _perAdultPriceControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Per Adult Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _perChildPriceControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Per Child Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _discountControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Discount',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: DropdownButton<String>(
                    value: _roomAvailabilityValues[index],
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down_outlined,
                        color: Colors.black),
                    items: _selectedAvailability.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (String? newvalue) {
                      setState(() {
                        _roomAvailabilityValues[index] = newvalue!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Color(0xFFFF1717)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder()),
                  ),
                  onPressed: () => _saveRoomDetails(index),
                  child: Text(
                    "Save Room",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteRoom(index),
                    ),
                  ],
                ),
                if (_isUploading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveRoomDetails(int index) async {
    final roomData = _rooms[index];

    final String availability = _roomAvailabilityValues[index] ?? 'no';

    if (roomData.containsKey('roomId') && roomData['roomId'] != null) {
      final DocumentReference roomRef = FirebaseFirestore.instance
          .collection('Hotels')
          .doc(widget.adminId.uid)
          .collection('Rooms')
          .doc(roomData['roomId']);

      await roomRef.update({
        'totalRooms': _totalRoomsControllers[index].text,
        'roomType': _roomTypeValues[index],
        'bedType': _bedTypeValues[index],
        'roomPrice': _roomPriceControllers[index].text,
        'perAdultPrice': _perAdultPriceControllers[index].text,
        'perChildPrice': _perChildPriceControllers[index].text,
        'discount': _discountControllers[index].text,
        'availability': availability,
        'facilities': _selectedFacilities[index],
        'hotelId': widget.adminId.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      final DocumentReference roomRef = FirebaseFirestore.instance
          .collection('Hotels')
          .doc(widget.adminId.uid)
          .collection('Rooms')
          .doc();

      await roomRef.set({
        'totalRooms': _totalRoomsControllers[index].text,
        'roomType': _roomTypeValues[index],
        'bedType': _bedTypeValues[index],
        'roomPrice': _roomPriceControllers[index].text,
        'perAdultPrice': _perAdultPriceControllers[index].text,
        'perChildPrice': _perChildPriceControllers[index].text,
        'discount': _discountControllers[index].text,
        'availability': _roomAvailabilityValues[index],
        'hotelId': widget.adminId.uid,
        'facilities': _selectedFacilities[index],
        'roomId': roomRef.id,
      });

      setState(() {
        _rooms[index]['roomId'] = roomRef.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room added successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    _fetchRoomData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawerwidget(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Room Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFFFF1717),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < _rooms.length; i++)
                        _buildRoomDetails(i),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xFFFF1717)),
                          shape: MaterialStateProperty.all(StadiumBorder()),
                        ),
                        onPressed: _addRoom,
                        child: const Text(
                          "+ Add Rooms",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
