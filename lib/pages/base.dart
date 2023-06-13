import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workspace/pages/notes.dart';
import 'package:workspace/pages/todo.dart';
import 'package:workspace/pages/incomplete_task.dart';
import 'package:workspace/pages/calender.dart';
import 'package:workspace/pages/shared_workspace.dart';
import 'package:workspace/pages/MyWorkspacePage.dart';
import 'package:workspace/pages/profile_page.dart';

import 'package:percent_indicator/percent_indicator.dart';



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }


  void _onTodoChanged() {
    setState(() {}); // Refresh the UI of HomePage
  }

  Widget buildPriorityList(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
      return ListView.builder(
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          DocumentSnapshot document = snapshot.data!.docs[index];
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          return ListTile(
            leading: Checkbox(
              value: data['checked'] ?? false,
              onChanged: (value) {
                document.reference.update({'checked': value}).then((value) {
                  _onTodoChanged(); // Call the local callback function
                });
              },
              activeColor: Colors.black,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            title: Text(
              "${data['todo'] ?? 'No todo'}",
              style: TextStyle(
                fontSize: 25.0,
                fontFamily: "lato",
                fontWeight: FontWeight.bold,
                color: data['checked'] ?? false ? Colors.black38 : Colors.black,
                decoration: data['checked'] ?? false ? TextDecoration.lineThrough : null,
              ),
            ),
          );
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }


  final CollectionReference notesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('notes');

  CollectionReference ref = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('todo');

  CollectionReference wref = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('workspace');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: notesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
            return Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Map<String, dynamic>? userData =
                          snapshot.data!.data() as Map<String, dynamic>?;

                          if (userData != null) {
                            String name = userData['name'];
                            String greeting = '';
                            String message = '';

                            // Get the current time
                            DateTime now = DateTime.now();

                            // Get the start and end of the current day
                            DateTime startOfDay = DateTime(now.year, now.month, now.day);
                            DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

                            // Check if there are any todos for the current day
                            bool hasTodos = false;
                            ref
                                .where('date', isGreaterThanOrEqualTo: startOfDay, isLessThanOrEqualTo: endOfDay)
                                .get()
                                .then((querySnapshot) {
                              hasTodos = querySnapshot.docs.any((doc) => doc['checked'] == true);
                            });

                            if (now.hour >= 0 && now.hour < 12) {
                              // Morning
                              greeting = 'Good Morning';
                              if (hasTodos) {
                                message = 'Congratulations, $name! You got a great head start for the day!';
                              } else {
                                message = 'Have a productive day ahead, $name!';
                              }
                            } else if (now.hour >= 12 && now.hour < 18) {
                              // Afternoon
                              greeting = 'Good Afternoon';
                              if (hasTodos) {
                                message = 'Congratulations, $name! You\'re making progress!';
                              } else {
                                message = "It's never too early nor too late, $name. Just start the work with full enthusiasm!";
                              }
                            } else {
                              // Evening
                              greeting = 'Good Evening';
                              if (hasTodos) {
                                message = 'Congratulations on completing a productive day, $name!';
                              } else {
                                message = 'Have a relaxing evening, $name!';
                              }
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 40),
                                  child: Text(
                                    greeting,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  message,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            );
                          }
                        }
                        return SizedBox.shrink();
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 185,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Color(0xDBE7ACFE),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text(
                                          'Notes 📖',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: documents.length,
                                            itemBuilder: (context, index) {
                                              String title = documents[index]
                                              ['title'] ??
                                                  'No title';
                                              return ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                title: Text(
                                                  title,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 8.0,
                                    right: 8.0,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => NotesPage(),
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          Icons.arrow_outward,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // SizedBox(height: 16),
                            SizedBox(height: 16),
                            Container(
                              width: 185,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Color(0xDB312E31),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: StreamBuilder<QuerySnapshot>(
                                stream: ref.where('date', isGreaterThanOrEqualTo: getStartOfDay(DateTime.now()), isLessThan: getEndOfDay(DateTime.now())).snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
                                    int totalItems = documents.length;
                                    int checkedItems = 0;

                                    for (var document in documents) {
                                      if ((document.data() as Map<String, dynamic>)['checked'] == true) {
                                        checkedItems++;
                                      }
                                    }

                                    double completionPercentage = totalItems > 0 ? (checkedItems / totalItems) * 100 : 0;

                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Daily Task  📋',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                            Text(
                                              '$checkedItems out of $totalItems done',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        CircularPercentIndicator(
                                          radius: 42,
                                          lineWidth: 3,
                                          percent: completionPercentage / 100,
                                          center: Text(
                                            '${completionPercentage.toInt()}%',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          progressColor: Colors.white,
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ],
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                              )

                            ),

                          ],
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 140,
                              height: 250,
                              decoration: BoxDecoration(
                                color: Color(0xFFEDDFBC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                stream: wref.snapshots().cast<QuerySnapshot<Map<String, dynamic>>>(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }

                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }

                                  // Access the documents from the collection
                                  List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
                                      snapshot.data?.docs ?? [];

                                  // Filter documents based on workspaceType
                                  List<QueryDocumentSnapshot<Map<String, dynamic>>> sharedWorkspaces =
                                  documents
                                      .where((doc) => doc.data()['workspaceType'] == 'shared')
                                      .toList();

                                  List<QueryDocumentSnapshot<Map<String, dynamic>>> privateWorkspaces =
                                  documents
                                      .where((doc) => doc.data()['workspaceType'] == 'private')
                                      .toList();

                                  return SingleChildScrollView(
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(10.0),
                                              child: Text(
                                                'Shared Workspace📖',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: ScrollPhysics(),
                                              padding: EdgeInsets.zero,
                                              itemCount: sharedWorkspaces.length,
                                              itemBuilder: (context, index) {
                                                String title = sharedWorkspaces[index].data()['title'] ?? 'No title';
                                                return Padding(
                                                  padding: EdgeInsets.only(left: 16.0), // Add left margin
                                                  child: ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Text(
                                                      title,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            Divider( // Add a partition line
                                              color: Colors.black,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(10.0),
                                              child: Text(
                                                'Private Workspace📖',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              padding: EdgeInsets.zero,
                                              itemCount: privateWorkspaces.length,
                                              itemBuilder: (context, index) {
                                                String title = privateWorkspaces[index].data()['title'] ?? 'No title';
                                                return Padding(
                                                  padding: EdgeInsets.only(left: 16.0), // Add left margin
                                                  child: ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Text(
                                                      title,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          bottom: 8.0,
                                          right: 8.0,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.black,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => MyWorkspacePage(),
                                                  ),
                                                );
                                              },
                                              child: Icon(
                                                Icons.arrow_outward,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '   Tasks today   📝 ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Todo(
                                          onTodoChanged: _onTodoChanged, // Pass the callback function to the Todo widget
                                        ),
                                      ),
                                    );
                                    setState(() {}); // Trigger reload after returning from the Todo page
                                  },
                                  child: Icon(
                                    Icons.arrow_outward,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Container(
                              padding: EdgeInsets.zero,
                              height: 200, // Set the height as needed
                              child: FutureBuilder<QuerySnapshot>(
                                future: ref.get(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<QueryDocumentSnapshot> documents = snapshot.data!.docs.reversed.toList();

                                    // Sort the documents based on priority
                                    documents.sort((a, b) {
                                      bool priorityA = a['priority'] ?? false;
                                      bool priorityB = b['priority'] ?? false;
                                      if (priorityA && !priorityB) {
                                        return -1; // a has higher priority than b
                                      } else if (!priorityA && priorityB) {
                                        return 1; // b has higher priority than a
                                      } else {
                                        return 0; // both have same priority
                                      }
                                    });

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: documents.length,
                                      itemBuilder: (context, index) {
                                        QueryDocumentSnapshot document = documents[index];
                                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                                        Timestamp? timestamp = data['date'] as Timestamp?;
                                        DateTime? todoDate = timestamp?.toDate();
                                        // Check if the date is today's date
                                        bool isToday = todoDate != null &&
                                            todoDate.year == DateTime.now().year &&
                                            todoDate.month == DateTime.now().month &&
                                            todoDate.day == DateTime.now().day;

                                        if (isToday) {
                                          Color bg = Colors.blueAccent;
                                          if (data['priority'] == true) {
                                            bg = Colors.greenAccent;
                                          }

                                          return Padding(
                                            padding: EdgeInsets.only(bottom: 8.0),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              color: bg,
                                              child: ListTile(
                                                leading: Checkbox(
                                                  value: data['checked'] ?? false,
                                                  onChanged: (value) {
                                                    // Update the 'checked' field in Firestore
                                                    document.reference.update({'checked': value}).then((value) {
                                                      print("Calling Set State");
                                                      setState(() {});
                                                    });
                                                  },
                                                  activeColor: Colors.black, // Set the checkbox color to black
                                                ),
                                                title: Row(
                                                  children: [
                                                    if (data['priority'] == true)
                                                      CircleAvatar(
                                                        child: Text('P'),
                                                      ), // Show the "P" icon for high priority tasks
                                                    SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        "${data['todo'] ?? 'No todo'}",
                                                        style: TextStyle(
                                                          fontSize: 24.0,
                                                          fontFamily: "lato",
                                                          fontWeight: FontWeight.bold,
                                                          color: data['checked'] ?? false ? Colors.black38 : Colors.black,
                                                          decoration: data['checked'] ?? false ? TextDecoration.lineThrough : null,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                trailing: IconButton(
                                                  icon: Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () {
                                                    // Delete the document from Firestore
                                                    document.reference.delete().then((value) {
                                                      print("Calling Set State");
                                                      setState(() {});
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return SizedBox.shrink(); // Hide the card if it doesn't match today's date
                                        }
                                      },
                                    );
                                  } else {
                                    return Center(
                                      child: Text('Loading...'),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },



      ),

      bottomNavigationBar: BottomAppBar(
          color: Colors.black, // Set the background color to black
          child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            // Handle home icon button press
          },
        ),
        IconButton(
          icon: Icon(Icons.notes),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotesPage()),
            );           },
        ),
        IconButton(
          icon: Icon(Icons.task),
          onPressed: () {
            // Call the Inctodo widget here
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Inctodo(
                  onTodoChanged: () {
                    // Handle the onTodoChanged callback here
                    // This function will be called when the todo is changed in the Inctodo widget
                    print('Todo changed');
                  },
                ),
              ),
            );
          },
        ),
        // IconButton(
        //   icon: Icon(Icons.calendar_today),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => CalendarPage()),
        //     );          },
        // ),
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );           },
        ),
      ],
    )
      )
    );
  }
}


