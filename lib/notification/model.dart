class Message {
  Message({
    this.id,
    this.title,
    this.content,
    this.time,
  });

  final int id;
  final String title;
  final String content;
  final DateTime time;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] == null ? null : json['id'],
      title: json['title'] == null ? null : json['title'],
      content: json['content'] == null ? null : json['content'],
      time: json['time'] == null ? null : DateTime.parse(json['time']),
    );
  }
}
