import 'package:cmtchat_app/colors.dart';

import 'package:cmtchat_app/models/local/message.dart';
import 'package:cmtchat_app/models/web/receipt.dart';

import 'package:cmtchat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SenderMessage extends StatelessWidget {
  final Message _message;

  const SenderMessage(this._message, {super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerRight,
      widthFactor: 0.75,
      child: Stack(
        children: [
          Padding(padding: const EdgeInsets.only(right: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: kPrimary,
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
                          ?.copyWith(height: 1.2, color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      DateFormat('h:mm a').format(_message.timestamp!),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isLightTheme(context) ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: _message.status == ReceiptStatus.read
                      ? Colors.green[700]
                      : Colors.grey,
                  size: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
