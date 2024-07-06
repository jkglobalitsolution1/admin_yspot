import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'drawer.dart';
import 'package:intl/intl.dart';

class GuestDetails extends StatefulWidget {
  final User adminId;
  const GuestDetails({Key? key, required this.adminId}) : super(key: key);

  @override
  State<GuestDetails> createState() => _GuestDetailsState();
}

class _GuestDetailsState extends State<GuestDetails> {
  Future<QuerySnapshot> fetchGuestDetails() async {
    try {
      return await FirebaseFirestore.instance
          .collection('Hotels')
          .doc(widget.adminId.uid)
          .collection("Guest Details")
          .get();
    } catch (e) {
      throw Exception('Error fetching guest details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const Drawerwidget(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: const Text(
            "Guest Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFFFF1717),
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: fetchGuestDetails(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No guest details found.'));
            }
            List<Widget> activeBookings = [];
            List<Widget> previousBookings = [];

            DateTime now = DateTime.now();
            DateTime today =
                DateTime(now.year, now.month, now.day); // Midnight of today

            snapshot.data!.docs.forEach((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              // Ensure the check-out date is correctly handled
              dynamic checkOutDateRaw = data['Check-Out Time & Date'];
              DateTime checkOutDate;
              if (checkOutDateRaw is String) {
                try {
                  checkOutDate =
                      DateFormat('dd/MM/yyyy').parse(checkOutDateRaw);
                } catch (e) {
                  checkOutDate = today; // Default to today if parsing fails
                }
              } else if (checkOutDateRaw is Timestamp) {
                checkOutDate = checkOutDateRaw.toDate();
              } else {
                checkOutDate = today; // Default to today if no valid date
              }

              if (checkOutDate.isAfter(today)) {
                activeBookings.add(
                  _buildBookingCard("Active Booking", data),
                );
              } else {
                previousBookings.add(
                  _buildBookingCard("Previous Booking", data, document.id),
                );
              }
            });

            return ListView(
              children: [
                ...activeBookings,
                ...previousBookings,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(String title, Map<String, dynamic> data,
      [String? docId]) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width =
            constraints.maxWidth < 600 ? constraints.maxWidth * 0.9 : 400;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSection(title, width, data, docId),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, double width, Map<String, dynamic> data,
      [String? docId]) {
    return Container(
      padding: EdgeInsets.all(8),
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: Colors.black54),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: title == "Active Booking"
                    ? Color(0xFFFF1717)
                    : Colors.black,
              ),
            ),
          ),
          SizedBox(height: 20),
          _buildRowDetailRows("Full Name", data['Full Name'] ?? 'N/A',
              "Room Type", data['Room Type'] ?? 'N/A'),
          SizedBox(height: 5),
          _buildRowDetailRows("Email Address", data['Email Address'] ?? 'N/A',
              "City", data['City'] ?? 'N/A'),
          SizedBox(height: 5),
          _buildRowDetailRows("Phone Number", data['Phone Number'] ?? 'N/A',
              "Payment Method", data['Payment Method'] ?? 'N/A'),
          SizedBox(height: 5),
          _buildRowDetailRows(
              "Check-In Time & Date",
              (data['Check-In Time & Date'] is Timestamp)
                  ? DateFormat('dd/MM/yyyy')
                      .format(data['Check-In Time & Date'].toDate())
                  : data['Check-In Time & Date'] ?? 'N/A',
              "Check-Out Time & Date",
              (data['Check-Out Time & Date'] is Timestamp)
                  ? DateFormat('dd/MM/yyyy')
                      .format(data['Check-Out Time & Date'].toDate())
                  : data['Check-Out Time & Date'] ?? 'N/A'),
          SizedBox(height: 5),
          _buildRowDetailRows(
              "Number Of Guests",
              data['No. Of Guests']?.toString() ?? 'N/A',
              "Room Count",
              data['Rooms Count']?.toString() ?? 'N/A'),
          SizedBox(height: 5),
          if (title == "Previous Booking") ...[
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                splashColor: Colors.white54,
                onTap: () {
                  // if (docId != null) {
                  //   _deleteBooking(docId);
                  // }
                },
                child: Container(
                  height: 25,
                  width: 50,
                  color: Color(0xFFFF1717),
                  child: Center(
                    child: Text(
                      "Delete",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(height: 5),
          Container(
            height: 45,
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDetailRows(
      String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(child: _buildDetailRow(label1, value1)),
        SizedBox(width: 10),
        Expanded(child: _buildDetailRow(label2, value2)),
      ],
    );
  }
}
