import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? title;

  const ImageViewer({
    Key? key,
    required this.imageUrl,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Image Preview'),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.error_outline,
                  color: AppTheme.error,
                  size: 48,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
