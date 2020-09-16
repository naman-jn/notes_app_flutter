import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/screens/note_detail.dart';
import 'package:notes_app/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NotesList extends StatefulWidget {
  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;
  int view=1;

  @override
  Widget build(BuildContext context) {

    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        actions: [IconButton(icon: Icon(icon()), onPressed: (){changeView();})],
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 2), 'Add Note');
        },
        child: Icon(Icons.add),
        tooltip: 'Add Note',
      ),
    );

  }

  ListView getNoteListView() {
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            margin: const EdgeInsets.all(5.0),
            elevation: 5,
            child: ListTile(
              contentPadding: const EdgeInsets.all(8.0),
              leading: CircleAvatar(
                backgroundColor:
                    getPriorityColor(this.noteList[position].priority),
                child: Icon(Icons.book),
              ),
              title: SelectableText(
                noteList[position].title,
                textScaleFactor: 1.1,
              ),
               subtitle: view!=1?null:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    noteList[position].description,
                    textScaleFactor: 1.1,
                  ),
                  SizedBox(height: 3),
                  Text(
                    noteList[position].date,
                    textScaleFactor: 0.8,
                  ),
                ],
              ),
              trailing: GestureDetector(
                  child: Icon(Icons.delete),
                  onTap: () {
                    _delete(context, noteList[position]);
                  }),
              onTap: () {
                navigateToDetail(
                    Note.withID(
                        noteList[position].id,
                        noteList[position].title,
                        noteList[position].date,
                        noteList[position].priority,
                        noteList[position].description),
                    'Edit Note');
              },
              onLongPress: (){HapticFeedback.vibrate();},
            ),
          );
        });
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      case 3:
        return Colors.greenAccent;
        break;

      default:
        return Colors.yellow;
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  void changeView(){
    setState(() {
      if(view==1)
        view=2;
      else
        view=1;
    });
  }

  IconData icon(){

    IconData icon;
    if(view==1)
    icon=Icons.view_list;
    else
    icon=Icons.view_agenda;
    return icon;
  }
}
