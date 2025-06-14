import 'package:flutter/material.dart';

class RefreshableList extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const RefreshableList({
    Key? key,
    required this.child,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
