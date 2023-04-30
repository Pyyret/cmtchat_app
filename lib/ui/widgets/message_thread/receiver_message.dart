import 'package:cmtchat_app/colors.dart';
import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiverMessage extends StatelessWidget {
  final Message _message;

  const ReceiverMessage(this._message, {super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.topLeft,
      widthFactor: 0.75,
      child: Stack(
        children: [
          Padding(padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                    decoration: BoxDecoration(
                      color: isLightTheme(context) ? kBubbleLight : kBubbleDark,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  position: DecorationPosition.background,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    child: Text(
                      _message.contents.trim(),
                      softWrap: true,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.2),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12.0, left: 12.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      DateFormat('h:mm a').format(_message.timestamp),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isLightTheme(context)
                            ? Colors.black54 : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            backgroundColor: isLightTheme(context)
                ? Colors.white : Colors.black,
            radius: 18,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
