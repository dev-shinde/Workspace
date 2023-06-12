import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum WorkspaceType {
  shared,
  private,
}

class Shared_Workspace extends StatefulWidget {
  const Shared_Workspace({Key? key}) : super(key: key);

  @override
  State<Shared_Workspace> createState() => _Shared_WorkspaceState();
}

class _Shared_WorkspaceState extends State<Shared_Workspace> {
  String? title;
  String? des;
  WorkspaceType workspaceType = WorkspaceType.shared;

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
                        backgroundColor:
                        MaterialStateProperty.all(Colors.blueAccent[700]),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 15.0, vertical: 1.0),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: add,
                      child: Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: "lato",
                          color: Colors.white,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(Colors.greenAccent[700]),
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
                Form(
                  child: Column(
                    children: [
                      Text(
                        'Workspace Type',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: "lato",
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      DropdownButton<WorkspaceType>(
                        value: workspaceType,
                        onChanged: (newValue) {
                          setState(() {
                            workspaceType = newValue!;
                          });
                        },
                        items: WorkspaceType.values
                            .map<DropdownMenuItem<WorkspaceType>>((value) {
                          return DropdownMenuItem<WorkspaceType>(
                            value: value,
                            child: Text(
                              value.toString().split('.').last,
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 15.0),
                      TextFormField(
                        decoration: InputDecoration.collapsed(
                          hintText: "Enter Your Title for Workspace",
                        ),
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: "lato",
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        onChanged: (_val) {
                          title = _val;
                        },
                      ),
                      SizedBox(height: 15.0),
                      TextFormField(
                        decoration: InputDecoration.collapsed(
                          hintText: "Enter Description for Workspace",
                        ),
                        style: TextStyle(
                          fontSize: 22.0,
                          fontFamily: "lato",
                          color: Colors.grey,
                        ),
                        onChanged: (_val) {
                          des = _val;
                        },
                        maxLines: 20,
                      ),
                    ],
                  ),
                ),
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
        .collection('workspace');

    var data = {
      'title': title,
      'description': des,
      'created': DateTime.now(),
      'workspaceType': workspaceType.toString().split('.').last,
    };

    ref.add(data);

    Navigator.pop(context);
  }
}
