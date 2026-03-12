import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';


/// Manages downloaded set images — shows sets, storage used, delete option.
class DownloadedSetsManager extends ConsumerWidget {
  const DownloadedSetsManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync = ref.watch(_downloadedSetsProvider);

    return setsAsync.when(
      data: (sets) {
        if (sets.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No sets downloaded yet.'),
          );
        }

        return Column(
          children: sets
              .map((set) => ListTile(
                    title: Text(set.setCode),
                    subtitle: Text(
                      '${set.imageCount} images - '
                      '${(set.sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Set Images'),
                            content: Text(
                                'Delete all images for ${set.setCode}?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await _deleteSet(set.setCode);
                          ref.invalidate(_downloadedSetsProvider);
                        }
                      },
                    ),
                  ))
              .toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error: $e'),
      ),
    );
  }
}

class _DownloadedSet {
  _DownloadedSet({
    required this.setCode,
    required this.imageCount,
    required this.sizeBytes,
  });

  final String setCode;
  final int imageCount;
  final int sizeBytes;
}

final _downloadedSetsProvider =
    FutureProvider<List<_DownloadedSet>>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final imagesDir = Directory(p.join(dir.path, 'card_images'));

  if (!imagesDir.existsSync()) return [];

  final sets = <_DownloadedSet>[];
  await for (final entity in imagesDir.list()) {
    if (entity is Directory) {
      final setCode = p.basename(entity.path);
      var count = 0;
      var size = 0;
      await for (final file in entity.list(recursive: true)) {
        if (file is File) {
          count++;
          size += await file.length();
        }
      }
      sets.add(_DownloadedSet(
        setCode: setCode,
        imageCount: count,
        sizeBytes: size,
      ));
    }
  }

  sets.sort((a, b) => a.setCode.compareTo(b.setCode));
  return sets;
});

Future<void> _deleteSet(String setCode) async {
  final dir = await getApplicationDocumentsDirectory();
  final setDir = Directory(p.join(dir.path, 'card_images', setCode));
  if (setDir.existsSync()) {
    await setDir.delete(recursive: true);
  }
}
