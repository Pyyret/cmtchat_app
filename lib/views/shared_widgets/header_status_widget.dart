import 'package:cmtchat_app/views/shared_widgets/profile_placeholder.dart';
import 'package:flutter/material.dart';

class HeaderStatus extends StatelessWidget {
  final String username;
  final String imageUrl;
  final bool online;
  const HeaderStatus(this.username, this.imageUrl, this.online, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Row(
        children: [
          const ProfilePlaceholder(50),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  username,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  online ? 'online' : 'offline',
                  style: Theme.of(context).textTheme.bodySmall
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
  
}