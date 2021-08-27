import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper/models/note.dart';
import 'dart:async';
import 'package:notekeeper/screens/note_detail.dart';
import 'package:notekeeper/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteListDetail extends StatefulWidget {
   final String appBarTitle;
  final  Note note;
  NoteListDetail(this.note,this.appBarTitle);
  @override
  _NoteListDetailState createState() => _NoteListDetailState(this.note,this.appBarTitle);
}

class _NoteListDetailState extends State<NoteListDetail> {
  String appBarTitle;
  Note note;
  DatabaseHelper helper=DatabaseHelper();
  static var _priorities = ["High", "Low"];
  TextEditingController titleEditingController = TextEditingController();
  TextEditingController decorationEditingController = TextEditingController();
  _NoteListDetailState(this.note,this.appBarTitle);
  @override
  Widget build(BuildContext context) {
    titleEditingController.text=note.title;
    decorationEditingController.text=note.description;
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
        child: ListView(
          children: [
            ListTile(
              title: DropdownButton(
                items: _priorities.map((String dropDownItem) {
                  return DropdownMenuItem(
                    child: Text(dropDownItem),
                    value: dropDownItem,
                  );
                }).toList(),
                value: getPriorityAsString(note.priority),
                onChanged: (value) {
                  setState(() {
                    updatePriorityAsInt(value);
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, right: 15.0),
              child: TextField(
                controller: titleEditingController,
                onChanged: (value) {
                  debugPrint('Something Changed');
                  updateTitle();
                },
                decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, right: 15.0),
              child: TextField(
                controller: decorationEditingController,
                onChanged: (value) {
                  debugPrint('Description changed');
                  updateDescription();
                },
                decoration: InputDecoration(
                    hintText: 'Decoration',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, right: 15.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Save'),
                      onPressed: () {
                        setState(() {
                          debugPrint('Save button clicked');
                          _save();
                        });
                      },
                    ),
                  ),
                  Container(
                    width: 5.0,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Delete'),
                      onPressed: () {
                        setState(() {
                          debugPrint('Delete button clicked');
                          _delete();
                        });
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  void updatePriorityAsInt(String value){
    switch(value){
      case "High":
        note.priority=1;
        break;
      case "Low":
        note.priority=2;
        break;
    }
  }
  String getPriorityAsString(int value){
    String priority;
    switch(value){
      case 1:
        priority=_priorities[0];
        break;
      case 2:
        priority=_priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle(){
    note.title=titleEditingController.text;
  }

  void updateDescription(){
    note.description=decorationEditingController.text;
  }

  void _save() async{
    
    note.date=DateFormat.yMMMd().format(DateTime.now());
    int result;
    if(note.id!=null){
      await helper.updateNote(note);
  }
    else {
      result=await helper.inserNote(note);
      if(result!=0){
        _showAlertDialog('Status', 'Note Saved Sucessfully');
      }
      else{
        _showAlertDialog('Status','Problem Saving Note');
      }
    }
}

void _delete() async{
    if(note.id==null) {
      _showAlertDialog('Status', 'No Note Deleted');
      return;
    }
    int result =await helper.deleteNote(note.id);
    if(result!=0){
      _showAlertDialog('Status', 'Note Deleted Suceesfully');
    }
    else{
      _showAlertDialog('Status','Error Occured while Deleting');
    }

}
void _showAlertDialog(String title,String message){
    AlertDialog alertDialog=AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (context)=>alertDialog);
}

}
