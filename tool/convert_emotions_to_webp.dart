// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final dir = Directory('assets/mascot/emotions');
  if (!dir.existsSync()) {
    print('Directory not found: ${dir.path}');
    exit(1);
  }

  // Check if cwebp is available
  final result = Process.runSync('where', ['cwebp']);
  final hasCwebp = result.exitCode == 0;

  if (!hasCwebp) {
    print('cwebp not found. Install it:');
    print('  choco install webp');
    print(
      '  or download from https://developers.google.com/speed/webp/download',
    );
    exit(1);
  }

  final pngs = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.png'))
      .toList();
  print('Found ${pngs.length} PNG files');

  int totalSaved = 0;
  int totalOriginal = 0;

  for (final png in pngs) {
    final name = png.path.split(Platform.pathSeparator).last;
    final webpPath = png.path.replaceAll('.png', '.webp');
    final result = Process.runSync('cwebp', [
      '-q',
      '80',
      png.path,
      '-o',
      webpPath,
    ]);

    if (result.exitCode != 0) {
      print('  ERROR $name: ${result.stderr}');
      continue;
    }

    final originalBytes = png.lengthSync();
    final webpBytes = File(webpPath).lengthSync();
    final saved = originalBytes - webpBytes;
    totalSaved += saved;
    totalOriginal += originalBytes;

    print('  $name: $originalBytes B -> $webpBytes B (saved $saved B)');

    png.deleteSync();
    print('  -> deleted $name');
  }

  final finalSize = totalOriginal - totalSaved;
  print(
    'Done: $totalOriginal bytes -> $finalSize bytes (saved $totalSaved B, ${totalOriginal > 0 ? (totalSaved / totalOriginal * 100).toStringAsFixed(1) : '0.0'}%)',
  );
}
