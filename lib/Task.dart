// Une doléance tâche, grievance or task in English
class Task {
  Task({this.uid = '0', this.what = '', this.where = '', this.comment = '', this.priority = 0});

  String uid = '';
  String what = '';
  String where = '';
  String comment = '';
  int priority = 0;
  String imageUrl = '';

  Task.fromJson(Map<String, dynamic> json) {
    this.uid = json['id'];
    this.what = json['what'];
    this.where = json['where'];
    this.comment = json['comment'];
    this.priority = int.parse(json['priority']);
    this.imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'what': what,
      'where': where,
      'comment': comment,
      'priority': priority,
    };
  }
}
