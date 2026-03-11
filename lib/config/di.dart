import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/scanner_service.dart';

/// Global Riverpod providers for dependency injection.

final scannerServiceProvider = Provider<ScannerService>((ref) {
  return ScannerService();
});
