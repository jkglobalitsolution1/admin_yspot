import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'drawer.dart';

class Room {
  final String roomType;
  final String bedType;
  DateTime checkIn;
  DateTime checkOut;
  int totalRooms; // Total number of rooms for this type

  Room({
    required this.roomType,
    required this.bedType,
    required this.checkIn,
    required this.checkOut,
    required this.totalRooms,
  });

  factory Room.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Room(
      roomType: data['roomType'] ?? '',
      bedType: data['bedType'] ?? '',
      checkIn: (data['Check-In Time & Date'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      checkOut: (data['Check-Out Time & Date'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      totalRooms: data['totalRooms'] ?? 0,
    );
  }
}

class RoomStatus extends StatefulWidget {
  final User admin;

  const RoomStatus({Key? key, required this.admin}) : super(key: key);

  @override
  State<RoomStatus> createState() => _RoomStatusState();
}

class _RoomStatusState extends State<RoomStatus> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Room> _rooms = [];
  List<Room> reservedRooms = [];
  List<Room> occupiedRooms = [];
  List<Room> availableRooms = [];

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      QuerySnapshot roomSnapshot = await _firestore
          .collection('Hotels')
          .doc(widget.admin.uid)
          .collection('Rooms')
          .get();

      List<Room> rooms =
          roomSnapshot.docs.map((doc) => Room.fromFirestore(doc)).toList();

      // Clear lists before categorizing
      reservedRooms.clear();
      occupiedRooms.clear();
      availableRooms.clear();

      // Fetch guest details and categorize rooms
      for (int i = 0; i < rooms.length; i++) {
        Room room = rooms[i];

        // Fetch guest details for this room type
        DocumentSnapshot guestDetailsSnapshot = await _firestore
            .collection('Hotels')
            .doc(widget.admin.uid)
            .collection('Guest Details')
            .doc(room.roomType) // Use roomType to fetch guest details
            .get();

        if (guestDetailsSnapshot.exists) {
          DateTime guestCheckIn =
              (guestDetailsSnapshot['Check-In Time & Date'] as Timestamp?)
                      ?.toDate() ??
                  DateTime.now();
          DateTime guestCheckOut =
              (guestDetailsSnapshot['Check-Out Time & Date'] as Timestamp?)
                      ?.toDate() ??
                  DateTime.now();

          // Categorize room based on guest check-in and check-out dates
          if (_isRoomReserved(room, guestCheckIn, guestCheckOut)) {
            reservedRooms.add(room);
          } else if (_isRoomOccupied(room, guestCheckIn, guestCheckOut)) {
            occupiedRooms.add(room);
          } else {
            availableRooms.add(room);
          }
        } else {
          // If guest details do not exist, assume room is available
          availableRooms.add(room);
        }
      }

      setState(() {
        _rooms = rooms;
      });
    } catch (e) {
      print('Error fetching rooms: $e');
    }
  }

  bool _isRoomReserved(
      Room room, DateTime guestCheckIn, DateTime guestCheckOut) {
    // Room is reserved if guest check-in is after room check-in
    return guestCheckIn.isAfter(room.checkIn) &&
        guestCheckIn.isBefore(room.checkOut);
  }

  bool _isRoomOccupied(
      Room room, DateTime guestCheckIn, DateTime guestCheckOut) {
    // Room is occupied if guest check-in is before room check-out and check-out is after room check-in
    return guestCheckIn.isBefore(room.checkOut) &&
        guestCheckOut.isAfter(room.checkIn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawerwidget(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "Room Status",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFFFF1717),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRoomCategoryContainer('Reserved', reservedRooms),
              _buildRoomCategoryContainer('Occupied', occupiedRooms),
              _buildRoomCategoryContainer('Available', availableRooms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCategoryContainer(String category, List<Room> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            category,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Text('Total Rooms: ${rooms.length}'),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            Room room = rooms[index];
            return Card(
              child: ListTile(
                title: Text('Room ${room.roomType} (${room.bedType})'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Check-in: ${room.checkIn.toLocal()}'),
                    Text('Check-out: ${room.checkOut.toLocal()}'),
                    Text('Total Rooms: ${room.totalRooms}'),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
