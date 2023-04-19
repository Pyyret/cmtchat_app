import 'package:flutter/cupertino.dart';

enum Typing { start, stop }

extension TypingParser on Typing {
  String value() {
    return toString().split('.').last;
  }
  static Typing fromString(String event) {
    return Typing.values.firstWhere((element) => element.value() == event);
  }
}

class TypingEvent {
  String get id => _id;
  final String to;
  final String from;
  final Typing event;
  String _id;

  TypingEvent({
    @required this.to,
    @required this.from,
    @required this.event
  });

  Map<String, dynamic> toJson() => {
    'to': to,
    'from': from,
    'event': event.value()
  };

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    var event = TypingEvent(
        from: json['from'],
        to: json['to'],
        event: TypingParser.fromString(json['event'])
    );
    event._id = json['id'];

    return event;
  }
}