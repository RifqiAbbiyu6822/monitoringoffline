import 'dart:io';
import 'package:flutter/material.dart';
import '../../constants/theme_constants.dart';

class PhotoViewer extends StatelessWidget {
  final String imagePath;
  final String? title;
  final String? subtitle;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const PhotoViewer({
    super.key,
    required this.imagePath,
    this.title,
    this.subtitle,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: ThemeConstants.grey200,
                ),
                child: File(imagePath).existsSync()
                    ? Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: ThemeConstants.iconLarge,
                                  color: ThemeConstants.grey500,
                                ),
                                SizedBox(height: ThemeConstants.spacing8),
                                Text(
                                  'Gambar tidak dapat dimuat',
                                  style: TextStyle(
                                    color: ThemeConstants.grey500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: ThemeConstants.iconLarge,
                              color: ThemeConstants.grey500,
                            ),
                            SizedBox(height: ThemeConstants.spacing8),
                            Text(
                              'Gambar tidak ditemukan',
                              style: TextStyle(
                                color: ThemeConstants.grey500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            
            // Content
            if (title != null || subtitle != null || onDelete != null)
              Padding(
                padding: const EdgeInsets.all(ThemeConstants.spacing12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null || onDelete != null)
                      Row(
                        children: [
                          if (title != null)
                            Expanded(
                              child: Text(
                                title!,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (onDelete != null)
                            IconButton(
                              onPressed: onDelete,
                              icon: const Icon(
                                Icons.delete_outline,
                                color: ThemeConstants.error,
                                size: ThemeConstants.iconSmall,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: ThemeConstants.spacing4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
