import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/services/db_extraction_service.dart';

/// Shows DB extraction progress during first launch setup.
class FirstLaunchScreen extends ConsumerStatefulWidget {
  const FirstLaunchScreen({super.key});

  @override
  ConsumerState<FirstLaunchScreen> createState() => _FirstLaunchScreenState();
}

class _FirstLaunchScreenState extends ConsumerState<FirstLaunchScreen> {
  double _progress = 0.0;
  String _status = 'Preparing card database...';
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _extractDb();
  }

  Future<void> _extractDb() async {
    final service = DbExtractionService();

    await for (final progress in service.extract()) {
      if (!mounted) return;
      setState(() {
        _progress = progress;
        if (progress < 1.0) {
          _status =
              'Extracting card database... ${(progress * 100).toInt()}%';
        } else {
          _status = 'Ready!';
          _done = true;
        }
      });
    }

    if (mounted && _done) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (mounted) context.go('/collection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_done) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 32),
              ] else
                const Icon(Icons.check_circle, size: 48, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                _status,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(value: _progress),
            ],
          ),
        ),
      ),
    );
  }
}
