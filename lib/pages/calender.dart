import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calender extends StatefulWidget {
  @override
  _CalenderState createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  DateTime _selectedDate = DateTime.now();
  late List<Map<String, dynamic>> _todoList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo Page'),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          SizedBox(height: 20),
          _buildTodoList(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime(DateTime.now().year - 1),
      lastDay: DateTime(DateTime.now().year + 1),
      focusedDay: _selectedDate,
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
        });
      },
      // Add other configuration options for the calendar if needed
      // ...
    );
  }

  Widget _buildTodoList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('todo')
          .where('date', isEqualTo: _selectedDate)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _todoList = snapshot.data!.docs.map((doc) => doc.data()).toList().cast<Map<String, dynamic>>();
          return ListView.builder(
            itemCount: _todoList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final todo = _todoList[index];
              final bool isAllChecked = _isAllChecked(todo);

              return Card(
                color: isAllChecked ? Colors.green : Colors.red,
                child: ListTile(
                  leading: Checkbox(
                    value: todo['checked'],
                    onChanged: (value) {
                      setState(() {
                        todo['checked'] = value;
                      });
                      _updateTodoItem(todo);
                    },
                  ),
                  title: Text(todo['title']),
                  // Add other fields or UI components as needed
                  // ...
                ),
              );
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  bool _isAllChecked(Map<String, dynamic> todo) {
    return _todoList.every((t) => t['checked']);
  }

  void _updateTodoItem(Map<String, dynamic> todo) {
    final docRef = FirebaseFirestore.instance
        .collection('todo')
        .doc(todo['id'].toString());
    docRef.update(todo);
  }
}
