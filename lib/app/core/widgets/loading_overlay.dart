import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
