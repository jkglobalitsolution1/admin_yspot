import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'drawer.dart';

class AdminProfile extends StatefulWidget {
  final User user;
  const AdminProfile({super.key, required this.user});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _hotelNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _hoteldocumentcontroller =
      TextEditingController();
  final TextEditingController _hotelwebsitecontroller = TextEditingController();
  File? profilepicture;
  File? hoteldocument;
  bool _isUploading = false;

  Future<void> _pickProfilepic() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowCompression: true);
    setState(() {
      profilepicture = result?.files.single.path != null
          ? File(result!.files.single.path!)
          : null;
    });
  }

  Future<void> _pickHotelDocument() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.any, allowCompression: true);
    setState(() {
      hoteldocument = result?.files.single.path != null
          ? File(result!.files.single.path!)
          : null;
    });
    if (hoteldocument != null) {
      await _uploadHotelDocument(result!.files.single.name);
    }
  }

  Future<void> _uploadHotelDocument(String fileName) async {
    try {
      if (hoteldocument != null) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('HotelDocuments')
            .child(widget.user.uid)
            .child(fileName);

        setState(() {
          _isUploading = true;
        });

        UploadTask uploadTask = storageReference.putFile(hoteldocument!);
        await uploadTask.whenComplete(() async {
          String documentUrl = await storageReference.getDownloadURL();
          _hoteldocumentcontroller.text = fileName;
          await FirebaseFirestore.instance
              .collection('admin profile')
              .doc(widget.user.uid)
              .update({
            'Hotel Document': {
              'url': documentUrl,
              'name': fileName,
            }
          });
        });

        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      print("Error uploading hotel document: $e");
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _saveData() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
            .collection('admin profile')
            .doc(userId)
            .get();
        if (userDataSnapshot.exists) {
          Map<String, dynamic> userData =
              userDataSnapshot.data() as Map<String, dynamic>;

          setState(() {
            _fullNameController.text = userData['Full Name'] ?? '';
            _hotelNameController.text = userData["Hotel Name"] ?? '';
            _emailController.text = userData['Email Address'] ?? '';
            _mobileNumberController.text = userData["Mobile Number"] ?? '';
            _locationController.text = userData["Address"] ?? '';
            _hotelwebsitecontroller.text = userData["Hotel Website"] ?? '';
            _hoteldocumentcontroller.text = userData["Hotel Document"] != null
                ? userData["Hotel Document"]["name"]
                : '';
          });
        }
      } catch (e) {
        print("Error: $e");
      }
    } else {
      // Handle case where user is not logged in
    }
  }

  @override
  void initState() {
    super.initState();
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawerEnableOpenDragGesture: true,
        drawer: Drawerwidget(),
        appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            centerTitle: true,
            title: Text(
              "Admin YSPOt",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Color(0xFFFF1717)),
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(8),
                  width: 400,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(color: Colors.black54)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: profilepicture != null
                                    ? FileImage(profilepicture!)
                                    : widget.user.photoURL != null
                                        ? NetworkImage(widget.user.photoURL!)
                                        : AssetImage("assets/icons/plus.png")
                                            as ImageProvider<Object>,
                              ),
                              CircleAvatar(
                                foregroundColor: Colors.white,
                                radius: 15,
                                backgroundColor: Color(0xFFFF1717),
                                child: IconButton(
                                  icon: Icon(
                                    CupertinoIcons.camera,
                                    size: 15,
                                  ),
                                  onPressed: _pickProfilepic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      buildTextField("Full Name", _fullNameController),
                      buildTextField("Hotel Name", _hotelNameController),
                      buildTextField("Hotel Website", _hotelwebsitecontroller),
                      buildTextField("Email Address", _emailController),
                      buildTextField("Mobile Number", _mobileNumberController,
                          isMobile: true),
                      buildTextField("Address", _locationController,
                          isAddress: true),
                      buildDocumentField(),
                      SizedBox(height: 10),
                      Center(
                        child: SizedBox(
                          height: 40,
                          width: 100,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xFFFF1717)),
                            ),
                            onPressed: updateProfile,
                            child: Text(
                              'Save',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isUploading) // Show transparent loading overlay if uploading
            Container(
              color: Colors.black.withOpacity(0.5), // Transparent background
              child: Center(
                child: CircularProgressIndicator(), // Loading indicator
              ),
            ),
        ]),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool isAddress = false, bool isMobile = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              counterText: '',
            ),
            keyboardType: isAddress
                ? TextInputType.multiline
                : (isMobile ? TextInputType.phone : TextInputType.text),
            maxLines: isAddress ? null : 1,
            maxLength: isMobile ? 10 : null,
            textInputAction:
                isAddress ? TextInputAction.newline : TextInputAction.next,
          ),
        ],
      ),
    );
  }

  Widget buildDocumentField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Submit Your Hotel Documents",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          TextField(
            controller: _hoteldocumentcontroller,
            readOnly: true,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: CircleAvatar(
                  maxRadius: 10,
                  backgroundColor: Color(0xFFFF1717),
                  child: IconButton(
                    icon: Icon(
                      CupertinoIcons.plus,
                      size: 20,
                      color: Colors.white,
                    ),
                    onPressed: _pickHotelDocument,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  void updateProfile() async {
    try {
      String? profilePictureUrl;
      if (profilepicture != null) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('ProfilePicture')
            .child(widget.user.uid);

        setState(() {
          _isUploading = true;
        });

        UploadTask uploadTask = storageReference.putFile(profilepicture!);
        await uploadTask.whenComplete(() async {
          profilePictureUrl = await storageReference.getDownloadURL();
        });
      }

      await widget.user.updatePhotoURL(profilePictureUrl);
      await widget.user.updateDisplayName(_fullNameController.text);

      await FirebaseFirestore.instance
          .collection('admin profile')
          .doc(widget.user.uid)
          .set({
        'Full Name': _fullNameController.text,
        'Hotel Name': _hotelNameController.text,
        'Email Address': _emailController.text,
        'Mobile Number': _mobileNumberController.text,
        'Address': _locationController.text,
        'Hotel Document': {
          'url': _hoteldocumentcontroller.text.isNotEmpty
              ? _hoteldocumentcontroller.text
              : null,
          'name': _hoteldocumentcontroller.text.isNotEmpty
              ? _hoteldocumentcontroller.text
              : null,
        },
        'Hotel Website': _hotelwebsitecontroller.text,
        'ProfilePicture': profilePictureUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      _saveData();

      setState(() {
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
