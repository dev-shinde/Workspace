import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workspace/pages/workspace_details_page.dart';
import 'package:workspace/pages/shared_workspace.dart';

class MyWorkspacePage extends StatefulWidget {
  @override
  _MyWorkspacePageState createState() => _MyWorkspacePageState();
}

class _MyWorkspacePageState extends State<MyWorkspacePage> {
  final CollectionReference wref = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('workspace');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => Shared_Workspace()),
          ).then((value) {
            print("Calling Set State");
            setState(() {});
          });
        },
        child: Icon(
          Icons.add,
          color: Colors.white70,
        ),
        backgroundColor: Color(0xFFE2B958),
      ),
      appBar: AppBar(
        title: Text('My Workspace'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
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

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                'Shared Workspace📖',
                                style: TextStyle(
                                  color: Colors.white,
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
                                String description = sharedWorkspaces[index].data()['description'] ?? '';
                                return Padding(
                                  padding: EdgeInsets.only(left: 16.0), // Add left margin
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WorkspaceDetailsPage(
                                            documentId: sharedWorkspaces[index].id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(70.0), // Add border radius
                                        child: Card(
                                          color: Colors.red,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.all(20.0),
                                            title: Text(
                                              title,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            Divider(
                              color: Colors.black,
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                'Private Workspace📖',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: privateWorkspaces.length,
                              itemBuilder: (context, index) {
                                String title = privateWorkspaces[index].data()['title'] ?? 'No title';
                                String description = privateWorkspaces[index].data()['description'] ?? '';
                                return Padding(
                                  padding: EdgeInsets.only(left: 16.0), // Add left margin
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WorkspaceDetailsPage(
                                            documentId: privateWorkspaces[index].id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(70.0), // Add border radius
                                        child: Card(
                                          color: Colors.red,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.all(20.0),
                                            title: Text(
                                              title,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
