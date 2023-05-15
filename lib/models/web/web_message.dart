class WebMessage {
  get webId => _webId;
  final String to;
  final String from;
  final DateTime timestamp;
  final String contents;
  String? _webId;

  WebMessage({
    required this.to,
    required this.from,
    required this.timestamp,
    required this.contents,
  });

  Map<String, dynamic> toJson() {
    var data = {
      'from' : from,
      'to' : to,
      'timestamp' : timestamp,
      'contents' : contents
    };
    if(_webId?.isNotEmpty ?? false) data['id'] = _webId!;
    return data;
  }

  factory WebMessage.fromJson(Map<String, dynamic> json) {
    final message = WebMessage(
        from: json['from'],
        to: json['to'],
        timestamp: json['timestamp'],
        contents: json['contents']
    );
    message._webId = json['id'];
    return message;
  }
}