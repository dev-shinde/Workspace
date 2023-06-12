import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workspace/pages/addnote.dart';
import 'package:workspace/pages/viewnotes.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {

  CollectionReference ref = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('notes');

  List<Color?> myColors = [
    Colors.yellow[200],
    Colors.red[200],
    Colors.green[200],
    Colors.deepPurple[200],
    Colors.purple[200],
    Colors.cyan[200],
    Colors.teal[200],
    Colors.tealAccent[200],
    Colors.pink[200],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddNote(),
            ),

          ).then((value){
            print("Calling Set State");
            setState(() {});
          });
        },
        child: Icon(
          Icons.add,
          color: Colors.white70,
        ),
        backgroundColor: Color(0xFFE2B958),
      ) ,

      appBar: AppBar(
        title: Text(
          'Notes',
          style: TextStyle(
            fontSize: 25.0,
            fontFamily: "lato", fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.limeAccent[700],
      ) ,

      body: FutureBuilder <QuerySnapshot> (
          future:  ref.get() ,
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  Random random = new Random();
                  Color? bg = myColors[random.nextInt(9)];
                  QueryDocumentSnapshot<Object?> document = snapshot.data!.docs.reversed.toList()[index] as QueryDocumentSnapshot<Object?>;
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  DateTime mydateTime = data['created'].toDate();

                  return Card(
                    margin: EdgeInsets.only(top: 20.0),
                    color: bg,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ViewNote(
                              data: data,
                              time: DateFormat.yMMMd().add_jm().format(mydateTime),
                              ref: document.reference,
                            ),
                          ),
                        ).then((value){
                          print("Calling Set State");
                          setState(() {});
                        });;
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${data['title'] ?? 'No title'}",
                              style: TextStyle(
                                fontSize: 24.0,
                                fontFamily: "lato",
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                DateFormat.yMMMd().add_jm().format(mydateTime),
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontFamily: "lato",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );

            }else{
              return Center(child: Text('Loading...'),
              );
            }
          }),
    );
  }
}
