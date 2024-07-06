import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'drawer.dart';

class ReviewPage extends StatefulWidget {
  final User adminId;
  const ReviewPage({super.key, required this.adminId});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add a review
  Future<void> _addReview(
      String guestName, String reviewDate, int ratings, String comments) async {
    await _firestore
        .collection('Hotels')
        .doc(widget.adminId.uid)
        .collection("Reviews")
        .add({
      'username': guestName,
      'date': reviewDate,
      'rating': ratings,
      'comments': comments,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawerwidget(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Reviews",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFFF1717),
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('Hotels')
            .doc(widget.adminId.uid)
            .collection("Reviews")
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final reviews = snapshot.data?.docs ?? [];
          final goodReviews =
              reviews.where((doc) => doc['rating'] >= 4).toList();
          final averageReviews =
              reviews.where((doc) => doc['rating'] == 3).toList();
          final badReviews =
              reviews.where((doc) => doc['rating'] <= 2).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildReviewListSection(
                      "Good", Color(0xFFFF1717), goodReviews),
                  _buildReviewListSection(
                      "Average", Color(0xFFFFA500), averageReviews),
                  _buildReviewListSection("Bad", Color(0xFF000000), badReviews),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewListSection(
      String label, Color color, List<DocumentSnapshot> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 10),
        ...reviews.map((review) => _buildReviewSection(review)).toList(),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReviewSection(DocumentSnapshot review) {
    String type = review['rating'] >= 4
        ? 'Good'
        : review['rating'] == 3
            ? 'Average'
            : 'Bad';
    Color color;
    switch (type) {
      case 'Good':
        color = Color(0xFFFF1717);
        break;
      case 'Average':
        color = Color(0xFFFFA500);
        break;
      case 'Bad':
        color = Color(0xFF000000);
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              _buildInfoColumn("Guest Name", review['username'] ?? ''),
              SizedBox(width: 10),
              _buildInfoColumn("Review Date", review['date']),
              SizedBox(width: 10),
              _buildInfoColumn("Ratings", review['rating'].toString()),
            ],
          ),
          SizedBox(height: 10),
          _buildCommentColumn("Comments", review['comments']),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Container(
          height: 35,
          width: 100,
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildCommentColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Text(value),
        ),
      ],
    );
  }
}
