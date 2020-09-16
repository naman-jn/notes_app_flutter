import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  _NoteDetailState createState() =>
      _NoteDetailState(this.note, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  String appBarTitle;
  Note note;

  DatabaseHelper helper = DatabaseHelper();

  _NoteDetailState(this.note, this.appBarTitle);

  static var _priority = ['High', 'Moderate', 'Low'];
  //var _currentItemSelected = 'High';

  TextEditingController _titleCtrl = TextEditingController();
  TextEditingController _descriptionCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle titleTextStyle = Theme.of(context).textTheme.headline6;
    TextStyle descriptionTextStyle = Theme.of(context).textTheme.subtitle1;

    _titleCtrl.text = note.title;
    _descriptionCtrl.text = note.description;

    return WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                moveToLastScreen();
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                ListTile(
                  title: DropdownButton(
                    style: titleTextStyle,
                    items: _priority
                        .map((value) => DropdownMenuItem(
                              child: Text(value),
                              value: value,
                            ))
                        .toList(),
                    value: getPriorityAsString(note.priority),
                    onChanged: (newValueSelected) {
                      setState(() {
                        //this._currentItemSelected = newValueSelected;
                        updatePriorityAsInt(newValueSelected);
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: titleTextStyle,
                    controller: _titleCtrl,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      updateTitle();
                    },
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter note title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: descriptionTextStyle,
                    controller: _descriptionCtrl,
                    keyboardType: TextInputType.multiline,
                    onChanged: (value) {
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Add note description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: RaisedButton(
                          onPressed: () {
                            setState(() {
                              _save();
                            });
                          },
                          child: Text(
                            'Save',
                            textScaleFactor: 1.3,
                          ),
                          textColor: Colors.white,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: RaisedButton(
                          onPressed: () {
                            setState(() {
                              _delete();
                            });
                          },
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.3,
                          ),
                          textColor: Colors.white,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context,true);
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Moderate':
        note.priority = 2;
        break;
      case 'Low':
        note.priority = 3;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priority[0];
        break;
      case 2:
        priority = _priority[1];
        break;
      case 3:
        priority = _priority[2];
        break;
    }
    return priority;
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = _titleCtrl.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = _descriptionCtrl.text;
  }

  void _save() async {

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {  // Case 1: Update operation
      result = await helper.updateNote(note);
    } else { // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {  // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {  // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {

    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }
}
