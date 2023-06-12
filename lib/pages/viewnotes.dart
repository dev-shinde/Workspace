import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ViewNote extends StatefulWidget {
  const ViewNote({Key? key, this.data, this.time, this.ref}) : super(key: key);

  final Map? data;
  final String? time;
  final DocumentReference? ref;

  @override
  State<ViewNote> createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  String? title;
  String? des;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.data?['image'] != null) {
      // Retrieve the download URL of the image from Firebase Storage
      getDownloadUrl(widget.data?['image']);
    }
  }

  Future<void> getDownloadUrl(String imagePath) async {
    try {
      final firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref().child(imagePath);
      final String downloadUrl = await ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });
    } catch (e) {
      print('Error getting download URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blueAccent[700]),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 15.0, vertical: 1.0),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: delete,
                      child: Icon(
                        Icons.delete_forever,
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.redAccent[700]),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12.0,
                ),
                Column(
                  children: [
                    Text(
                      "${widget.data?['title']}",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: "lato",
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    imageUrl != null ? Image.network(imageUrl!) : SizedBox(),
                    SizedBox(height: 10.0),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      padding: const EdgeInsets.only(top: 15.0),
                      child: SingleChildScrollView(
                        child: Text(
                          "${widget.data?['description']}",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "lato",
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void delete() async {
    if (widget.ref != null) {
      await widget.ref!.delete();
      Navigator.pop(context);
    }
  }
}
