import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class WorkspaceDetailsPage extends StatefulWidget {
  final String documentId;

  WorkspaceDetailsPage({required this.documentId});

  @override
  _WorkspaceDetailsPageState createState() => _WorkspaceDetailsPageState();
}

class _WorkspaceDetailsPageState extends State<WorkspaceDetailsPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  StreamSubscription<DocumentSnapshot>? _workspaceSubscription;

  @override
  void initState() {
    super.initState();
    // Start listening for changes in the current user's workspace
    _startWorkspaceSubscription();
  }

  @override
  void dispose() {
    // Cancel the workspace subscription when the widget is disposed
    _cancelWorkspaceSubscription();
    super.dispose();
  }

  void _startWorkspaceSubscription() {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _workspaceSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workspace')
        .doc(widget.documentId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          // Handle the updated workspace data here
          // For example, you can update the workspaceData variable
          var workspaceData = snapshot.data() as Map<String, dynamic>;
          // Do something with the updated workspace data
        });
      }
    });
  }

  void _cancelWorkspaceSubscription() {
    _workspaceSubscription?.cancel();
    _workspaceSubscription = null;
  }

  void _addUserToWorkspace() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();

    try {
      // Get the user document from the users collection based on the email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User with the provided email not found.'),
          ),
        );
      } else {
        // Get the user's workspace collection document
        DocumentReference workspaceRef = FirebaseFirestore.instance
            .collection('users')
            .doc(querySnapshot.docs[0].id)
            .collection('workspace')
            .doc(widget.documentId);

        // Get the current user's workspace collection document
        DocumentReference currentUserWorkspaceRef = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('workspace')
            .doc(widget.documentId);

        // Get the current user's workspace document data
        DocumentSnapshot currentUserWorkspaceSnapshot =
        await currentUserWorkspaceRef.get();

        if (currentUserWorkspaceSnapshot.exists) {
          // Check if the current user's workspace is shared
          bool isShared =
              (currentUserWorkspaceSnapshot.data() as Map<String, dynamic>)['workspaceType'] == 'shared';

          if (isShared) {
            // Merge the current user's workspace data with the added user's workspace data
            await workspaceRef.set(
              currentUserWorkspaceSnapshot.data(),
              SetOptions(merge: true),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User added to the workspace successfully.'),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cannot add user to a private workspace.'),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Current user workspace not found.'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding user to workspace: $e'),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workspace Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('workspace')
            .doc(widget.documentId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('Workspace not found.'),
            );
          }

          var workspaceData = snapshot.data!.data() as Map<String, dynamic>;
          String workspaceType = workspaceData['workspaceType'] ?? '';

          String title = workspaceData['title'] ?? 'No title';
          String description = workspaceData['description'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16),
                Card(
                  color: Colors.blue,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Title: $title',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  color: Colors.green,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        '$description',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                if (workspaceType == 'shared')
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Add User to Workspace',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _addUserToWorkspace,
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : Text('Add User'),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

