import 'package:flutter/material.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/screens/note_detail.dart';
import 'package:notekeeper/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper=DatabaseHelper();
  List<Note>noteList;
  int count=0;
  @override
  Widget build(BuildContext context) {
    if(noteList==null){
     noteList=[];
     updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Notekeeper'),
      ),
      body: getNoteList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
        navigateToPage(Note(' ',2,' ',' '),'Add Note');
        },
      ),
    );
  }

  ListView getNoteList() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getColor(noteList[position].priority),
              child: getPriorityIcon(noteList[position].priority),
            ),
            title: Text(noteList[position].title),
            subtitle: Text(noteList[position].date),
            trailing: GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onTap: (){
                _delete(context, noteList[position]);
              },
            ),
            onTap: () {
             navigateToPage(noteList[position],'Edit Note');
            },
          ),
        );
      },
    );
  }

  void _delete(BuildContext context, Note note) async{
    int result=await databaseHelper.deleteNote(note.id);
    if(result!=0){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note Sucessfully Deleted'),
        )
      );
      updateListView();
    }
  }

  // Return the prioirty color
  Color getColor(int priority){
    switch(priority){
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }
  // Return prioirty icon
  Icon getPriorityIcon(int priority){
    switch(priority){
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }
  void navigateToPage(Note note,String title) async {
     await Navigator.push(context, MaterialPageRoute(builder: (context){
      return NoteListDetail(note,title);
    }));
    updateListView();
  }

  void updateListView() {
    final Future<Database> dbFuture=databaseHelper.intializeDatabase();
    dbFuture.then((database){
      Future<List<Note>>noteListFuture=databaseHelper.getNoteList();
      noteListFuture.then((noteList1){
        setState(() {
          this.count=noteList1.length;
          this.noteList=noteList1;
        });
      });
    });

  }
}
