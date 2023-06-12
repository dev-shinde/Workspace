import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:workspace/pages/notes.dart';
import 'package:workspace/pages/base.dart';


GoogleSignIn googleSignIn = GoogleSignIn();
FirebaseAuth auth = FirebaseAuth.instance;
CollectionReference users = FirebaseFirestore.instance.collection('users');

Future<bool> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken
      );

      final UserCredential authResult = await auth.signInWithCredential(credential);

      final User? user = authResult.user;

      var userData = {
        'name' : googleSignInAccount.displayName,
        'provider' : 'google',
        'photoUrl' : googleSignInAccount.photoUrl,
        'email' : googleSignInAccount.email,
      };

      final User? authenticatedUser = authResult.user;

      if (authenticatedUser != null) {
        users.doc(authenticatedUser.uid).get().then((doc) {
          if (doc.exists) {
            doc.reference.update(userData);

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => HomePage(),
              ),
            );
          } else {
            users.doc(authenticatedUser.uid).set(userData);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );

          }
        });
      }

      return true; // Sign-in successful
    }
  } catch (PlatformException) {
    print(PlatformException);
    print("Sign in not Successful !");
  }

  return false; // Sign-in unsuccessful
}
