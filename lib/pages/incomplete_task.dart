import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workspace/pages/add_todo.dart';

class Inctodo extends StatefulWidget {
  final Function() onTodoChanged; // Add this line

  const Inctodo({Key? key, required this.onTodoChanged}) : super(key: key); // Modify the constructor

  @override
  State<Inctodo> createState() => _InctodoState();
}

class _InctodoState extends State<Inctodo> {
  DateTime currentDate = DateTime.now();

  void _onTodoChanged() {
    widget.onTodoChanged(); // Call the callback function defined in the HomePage widget
    setState(() {}); // Refresh the Todo widget's UI
  }

  CollectionReference ref = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('todo');

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
      appBar: AppBar(
        title: Text(
          'Your incomplete Tasks',
          style: TextStyle(
            fontSize: 25.0,
            fontFamily: "lato",
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.lightGreenAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ref.where('checked', isEqualTo: false).snapshots(), // Use a stream instead of a future, and filter for unchecked tasks
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                Random random = Random();
                Color? bg = myColors[random.nextInt(9)];
                QueryDocumentSnapshot<Object?> document = snapshot.data!.docs.reversed.toList()[index] as QueryDocumentSnapshot<Object?>;
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Card(
                    margin: EdgeInsets.only(top: 20.0),
                    color: bg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(55.0), // Adjust the value as per your preference
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: data['checked'] ?? false,
                        onChanged: (value) {
                          document.reference.update({'checked': value}).then((value) {
                            _onTodoChanged();
                          });
                        },
                        activeColor: Colors.black,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${data['todo'] ?? 'No todo'}",
                            style: TextStyle(
                              fontSize: 24.0,
                              fontFamily: "lato",
                              fontWeight: FontWeight.bold,
                              color: data['checked'] ?? false ? Colors.black38 : Colors.black,
                              decoration: data['checked'] ?? false ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (data['priority'] == true) SizedBox(width: 12.0),
                          if (data['priority'] == true)
                            CircleAvatar(
                              child: Text('P'),
                            ),
                          if (data['date'] != null) SizedBox(height: 12.0),
                          if (data['date'] != null)
                            Text(
                              "${(data['date'] as Timestamp).toDate().toString().split(" ")[0]}",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "lato",
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          document.reference.delete();
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text('Loading...'),
            );
          }
        },
      ),
    );
  }
}
