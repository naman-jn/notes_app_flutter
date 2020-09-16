class Note{
  int _id;
  String _title;
  String _description;
  String _date;
  int _priority;

  Note.withID(this._id, this._title, this._date, this._priority, [this._description]);

  Note(this._title, this._date, this._priority, [this._description]);

  int get priority => _priority;

  set priority(int value) {
    if(value>=1 && value<=3)
    _priority = value;
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get title => _title;

  set title(String value) {
    if(value.length<=50)
    _title = value;
  }

  int get id => _id;

 // Map<String,dynamic> toMap1(){
 //    var map=Map<String,dynamic>();
 //
 //    if(id!=null){
 //     map['id']=_id;
 //    }
 //    map['title']=_title;
 //    map['description']=_description;
 //    map['date']=_date;
 //    map['priority']=_priority;
 //   return map;
 //  }

  Map<String,dynamic> toMap() {
    return {

      if(id != null)
        'id': _id,
      'title': _title,
      'description': _description,
      'date': _date,
      'priority': _priority,
    };
  }

  Note.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._priority = map['priority'];
    this._date = map['date'];
  }


}