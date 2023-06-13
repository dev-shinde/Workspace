import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNote extends StatefulWidget {
  const AddNote({Key? key}) : super(key: key);

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {

  String? title;
  String? des;

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
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0), // Adjust the border radius as desired
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all(Colors.blueAccent[700],),
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 1.0,
                          ))
                      ),
                    ),
                    //
                  ],
                ),

                SizedBox(
                  height: 12.0,
                ),

                Form(child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20.0), // Set the desired bottom margin
                      width: 700, // Set the desired width
                      height: 40, // Set the desired height
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration.collapsed(
                          hintText: "Enter Title",
                          hintStyle: TextStyle(
                            fontSize: 25.0,
                            fontFamily: "lato",
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 25.0,
                          fontFamily: "lato",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        onChanged: (_val) {
                          title = _val;
                        },
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(bottom: 25.0), // Set the desired bottom margin
                      decoration: BoxDecoration(
                        color: Color(0xFFFFDF95),
                        borderRadius: BorderRadius.circular(30.0), // Add the desired border radius
                      ),
                      height: MediaQuery.of(context).size.height * 0.4,
                      padding: const EdgeInsets.only(top: 15.0),
                      child: TextFormField(
                        decoration: InputDecoration.collapsed(
                          hintText: "Enter Description",
                          hintStyle: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "lato",
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.0,
                          fontFamily: "lato",
                          color: Colors.black,
                        ),
                        onChanged: (_val) {
                          des = _val;
                        },
                        maxLines: 20,
                      ),

                    ),
                  ],
                )),

                ElevatedButton(
                  onPressed: add,
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: "lato",
                      color: Colors.white,
                    ),),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0), // Adjust the border radius as desired
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(Colors.greenAccent[700],),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 10.0,
                      ))
                  ),
                )
              ],

            ),
          ),
        ),
      ),
    );
  }

  void add() async {
    CollectionReference ref = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('notes');

    var data = {
      'title': title,
      'description': des,
      'created': DateTime.now(),
    };

    ref.add(data);

    Navigator.pop(context);

  }

}

