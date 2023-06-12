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
                          backgroundColor: MaterialStateProperty.all(Colors.blueAccent[700],),
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 1.0,
                          ))
                      ),
                    ),
                    //
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
                          backgroundColor: MaterialStateProperty.all(Colors.greenAccent[700],),
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 8.0,
                          ))
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 12.0,
                ),

                Form(child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration.collapsed(
                          hintText: "Enter Your Notes"
                      ),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: "lato", fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      onChanged: (_val){
                        title = _val;
                      },
                    ),

                    Container(
                      height: MediaQuery.of(context).size.height * 0.75,
                      padding: const EdgeInsets.only(top: 15.0),
                      child: TextFormField(
                        decoration: InputDecoration.collapsed(
                            hintText: "Enter Description"
                        ),
                        style: TextStyle(
                          fontSize: 22.0,
                          fontFamily: "lato",
                          color: Colors.grey,
                        ),
                        onChanged: (_val){
                          des = _val;
                        },
                        maxLines: 20,
                      ),
                    ),

                  ],
                ))
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

