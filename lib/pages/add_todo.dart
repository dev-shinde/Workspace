import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class AddTodo extends StatefulWidget {
  const AddTodo({Key? key}) : super(key: key);

  @override
  State<AddTodo> createState() => _AddTodoState();
}

DateTime selectedDate = DateTime.now();

class _AddTodoState extends State<AddTodo> {
  String? todo;
  bool priorityCheckboxValue = false;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

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
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 1.0,
                        )),
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
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                          horizontal: 25.0,
                          vertical: 8.0,
                        )),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12.0,
                ),
                Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration.collapsed(
                        hintText: "Enter Your todo for today",
                      ),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: "lato",
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      onChanged: (_val) {
                        todo = _val;
                      },
                      maxLines: 20,
                    ),
                    CheckboxListTile(
                      title: Text('Priority'),
                      value: priorityCheckboxValue,
                      onChanged: (value) {
                        setState(() {
                          priorityCheckboxValue = value!;
                        });
                      },
                    ),
                    SizedBox(
                      height: 2.0,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _selectDate(context);
                      },
                      child: Text('Select Date'),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      'Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void add() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final todoCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('todo');

    final now = tz.TZDateTime.now(tz.local);

    // Calculate the end of the day
    final endOfDay = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    ).add(const Duration(seconds: 1)); // Add 1 second to reach the next day

    final data = {
      'todo': todo,
      'created': now,
      'deleteAt': endOfDay,
      'priority': priorityCheckboxValue,
      'checked': false,
      'date': selectedDate, // Include the selected date in the data
    };

    await todoCollectionRef.add(data);

    Navigator.pop(context);
  }
}
