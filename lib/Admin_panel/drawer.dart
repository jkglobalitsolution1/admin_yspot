import 'package:adminyspot/Admin_panel/Admin_profile.dart';
import 'package:adminyspot/Admin_panel/Room_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Authentication/login_screen.dart';
import 'Guest_details.dart';
import 'Hotel_page.dart';
import 'Payments.dart';
import 'Review_page.dart';
import 'Room_details.dart';

class Drawerwidget extends StatefulWidget {
  const Drawerwidget({super.key});

  @override
  State<Drawerwidget> createState() => _DrawerwidgetState();
}

class _DrawerwidgetState extends State<Drawerwidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shadowColor: Colors.white,
      width: 200,
      backgroundColor: Color(0xFFFF1717),
      child: Column(
        children: [
          Container(
              height: 100,
              width: 200,
              child: Image.asset("assets/logo assets/yspot_logo.png")),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminProfile(user: FirebaseAuth.instance.currentUser!),
                  ));
            },
            splashColor: Colors.black,
            leading: Icon(
              Icons.person_2_outlined,
              color: Colors.white,
            ),
            title: Text(
              "Admin Profile",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HotelDetails(
                      user: FirebaseAuth.instance.currentUser!,
                    ),
                  ));
            },
            splashColor: Colors.black,
            leading: Icon(
              Icons.local_hotel,
              color: Colors.white,
            ),
            title: Text(
              "Hotels",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomDetails(
                      adminId: FirebaseAuth.instance.currentUser!,
                    ),
                  ));
            },
            splashColor: Colors.black,
            leading: Icon(
              Icons.meeting_room,
              color: Colors.white,
            ),
            title: Text(
              "Rooms",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GuestDetails(
                      adminId: FirebaseAuth.instance.currentUser!,
                    ),
                  ));
            },
            splashColor: Colors.black,
            leading: Icon(
              Icons.person_outline_sharp,
              color: Colors.white,
            ),
            title: Text(
              "Guest Details",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Payments(
                      adminId: FirebaseAuth.instance.currentUser!,
                    ),
                  ));
            },
            splashColor: Colors.black,
            leading: Icon(
              Icons.attach_money,
              color: Colors.white,
            ),
            title: Text(
              "Payments",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewPage(
                      adminId: FirebaseAuth.instance.currentUser!,
                    ),
                  ));
            },
            splashColor: Colors.black,
            leading: Icon(
              Icons.star,
              color: Colors.white,
            ),
            title: Text(
              "Reviews",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RoomStatus(
                          admin: FirebaseAuth.instance.currentUser!)));
            },
            splashColor: Colors.black,
            leading: Icon(
              Icons.clean_hands_sharp,
              color: Colors.white,
            ),
            title: Text(
              "Room Status",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: () {
              _logout(context);
            },
            splashColor: Colors.black,
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            title: Text(
              "Log Out",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Are you sure?'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();

                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  );

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminLogin(),
                      ));
                },
                child: const Text('Yes'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('No'),
              ),
            ],
          );
        });
  }
}
