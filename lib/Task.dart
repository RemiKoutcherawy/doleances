// Une doléance tâche, grievance or task in English
class Task {
  Task(
      {this.id = '0',
      this.what = '',
      this.where = '',
      this.comment = '',
      this.priority = 0,
      this.timestamp = 0,
      });

  String id = '';
  String what = '';
  String where = '';
  String comment = '';
  int priority = 0;
  int timestamp = 0;
  String imageUrl = '';

  Task.fromJson(Map<String, dynamic> json) {
    print (json);
    this.id = json['id'];
    this.what = json['what'];
    this.where = json['where'];
    this.comment = json['comment'];
    this.priority = int.parse(json['priority']);
    this.imageUrl = json['imageUrl'];
    this.timestamp = int.parse(json['timestamp']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'what': what,
      'where': where,
      'comment': comment,
      'priority': priority,
      'timestamp': timestamp,
    };
  }
}
