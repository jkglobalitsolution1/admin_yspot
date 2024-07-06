import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'drawer.dart';

class HotelDetails extends StatefulWidget {
  final User user;
  const HotelDetails({Key? key, required this.user}) : super(key: key);

  @override
  State<HotelDetails> createState() => _HotelDetailsState();
}

class _HotelDetailsState extends State<HotelDetails> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  List<File> _selectedImages = [];
  List<String> _imageUrls = [];
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  // List of predefined facilities
  final List<String> _facilityOptions = [
    'Wi-Fi',
    'Parking',
    'Pool',
    'Gym',
    'Restaurant',
    'Spa',
    'Bar',
    'Room Service',
    'Laundry',
    'Air Conditioning',
  ];

  List<String> _selectedFacilities = [];
  String? _selectedFacility;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _getImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages
            .addAll(images.map((image) => File(image.path)).toList());
      });
    }
  }

  Future<void> _loadData() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
            .collection('Hotels')
            .doc(userId)
            .get();
        if (userDataSnapshot.exists) {
          Map<String, dynamic> userData =
              userDataSnapshot.data() as Map<String, dynamic>;

          setState(() {
            _nameController.text = userData['Hotel Name'] ?? '';
            _roomsController.text = userData['No. Of Rooms'] ?? '';
            _priceController.text = userData["Room Price"] ?? '';
            _addressController.text = userData["Hotel Address"] ?? '';
            _imageUrls = List<String>.from(userData["Property Images"] ?? []);
            _selectedFacilities =
                List<String>.from(userData["Accommodation Facilities"] ?? []);
          });
        }
      } catch (e) {
        print("Error: $e");
      }
    } else {
      // Handle case where user is not logged in
    }
  }

  Future<void> _deleteImage(String imageUrl, int index) async {
    try {
      // Delete image from Firebase Storage
      Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();

      // Remove image URL from list
      setState(() {
        _imageUrls.removeAt(index);
      });

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('Hotels')
          .doc(widget.user.uid)
          .update({
        'Property Images': _imageUrls,
      });
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawerwidget(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "Hotel Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFFFF1717),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  border: Border.all(color: Colors.black54),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Column(
                          children: [
                            _selectedImages.isNotEmpty || _imageUrls.isNotEmpty
                                ? GridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: 3,
                                    children: List.generate(
                                      _selectedImages.length +
                                          _imageUrls.length,
                                      (i) {
                                        if (i < _selectedImages.length) {
                                          return ImageCard(
                                            image: _selectedImages[i],
                                            onDelete: () async {
                                              setState(() {
                                                _selectedImages.removeAt(i);
                                              });
                                            },
                                          );
                                        } else {
                                          int imageUrlIndex =
                                              i - _selectedImages.length;
                                          return ImageCard(
                                            imageUrl: _imageUrls[imageUrlIndex],
                                            onDelete: () async {
                                              await _deleteImage(
                                                  _imageUrls[imageUrlIndex],
                                                  imageUrlIndex);
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  )
                                : Icon(Icons.add,
                                    size: 40, color: Colors.black),
                            SizedBox(
                              height: 5,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  shape:
                                      WidgetStateProperty.all(LinearBorder()),
                                  backgroundColor: WidgetStateProperty.all(
                                      Color(0xFFFF1717))),
                              onPressed: _getImages,
                              child: Text(
                                "Add Images",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )),
                    SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Hotel Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Room Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _roomsController,
                      decoration: InputDecoration(
                        labelText: 'Add No. Of Rooms',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: _selectedFacilities.map((facility) {
                        return Chip(
                          label: Text(facility),
                          onDeleted: () {
                            setState(() {
                              _selectedFacilities.remove(facility);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    // Dropdown for selecting facilities
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Facility',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedFacility,
                      items: _facilityOptions.map((String facility) {
                        return DropdownMenuItem<String>(
                          value: facility,
                          child: Row(
                            children: [
                              Icon(
                                  Icons.check), // Use different icons as needed
                              SizedBox(width: 8),
                              Text(facility),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null &&
                              !_selectedFacilities.contains(newValue)) {
                            _selectedFacilities.add(newValue);
                          }
                          _selectedFacility = null;
                        });
                      },
                    ),

                    SizedBox(height: 10),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(LinearBorder()),
                        backgroundColor:
                            WidgetStateProperty.all(Color(0xFFFF1717)),
                      ),
                      onPressed: updateHotelDetails,
                      child: Text(
                        'Save',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateHotelDetails() async {
    try {
      setState(() {
        _isUploading = true;
      });

      final List<String> newImageUrls = [];
      for (var image in _selectedImages) {
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('Hotel Pictures')
            .child(widget.user.uid)
            .child(DateTime.now().millisecondsSinceEpoch.toString());

        final UploadTask uploadTask = storageReference.putFile(image);
        await uploadTask.whenComplete(() async {
          final hotelpicUrl = await storageReference.getDownloadURL();
          newImageUrls.add(hotelpicUrl);
        });
      }

      // Combine old and new image URLs
      final List<String> allImageUrls = [..._imageUrls, ...newImageUrls];

      await FirebaseFirestore.instance
          .collection('Hotels')
          .doc(widget.user.uid)
          .set({
        'Hotel Name': _nameController.text,
        'Accommodation Facilities': _selectedFacilities,
        'No. Of Rooms': _roomsController.text,
        'Room Price': _priceController.text,
        'Hotel Address': _addressController.text,
        'Property Images': allImageUrls,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        _selectedImages.clear();
        _imageUrls = allImageUrls;
        _isUploading = false;
      });
    } catch (e) {
      print("Failed: $e");
      setState(() {
        _isUploading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Profile not updated'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
}

class ImageCard extends StatelessWidget {
  final File? image;
  final String? imageUrl;
  final VoidCallback onDelete;

  const ImageCard({Key? key, this.image, this.imageUrl, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: image != null
                  ? FileImage(image!)
                  : NetworkImage(imageUrl!) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ),
      ],
    );
  }
}
