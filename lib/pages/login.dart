import 'package:flutter/material.dart';
import 'package:workspace/controller/google_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:Column(
        children: [
          Expanded(child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/cover.png',
              ),
              ),

            ),
          ),
          ),
          Text('Create and make your own list',
            style: TextStyle(
              fontSize: 36.0,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                signInWithGoogle(context);
              },
              child: Row(
            children: [
              Text("Continue with Google",
              ),
            ],
          ))
        ],
    )
    )
    );
  }
}
