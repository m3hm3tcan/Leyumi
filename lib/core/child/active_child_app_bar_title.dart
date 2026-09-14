import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'active_child_provider.dart';

class ActiveChildAppBarTitle extends StatelessWidget {
  const ActiveChildAppBarTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final childName = context.watch<ActiveChildProvider>().activeChild?.name;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        if (childName != null)
          Text(
            childName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
      ],
    );
  }
}
