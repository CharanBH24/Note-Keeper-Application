import 'package:flutter/material.dart';
import 'package:notekeeper/screens/note_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notekeeper App',
      theme: ThemeData(primarySwatch: Colors.orange),
      debugShowCheckedModeBanner: false,
      home: NoteList(), // This will display all the notes given by the app according to priority
    );
  }
}
