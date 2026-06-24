import 'package:flutter/material.dart';
import 'package:testly/core/network/api_exception.dart';

class ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isOffline = error is ApiException && (error as ApiException).isOffline;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.error_outline,
              size: 48,
              color: isOffline ? Colors.grey : Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              isOffline
                  ? 'No internet connection'
                  : error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (isOffline) ...[
              const SizedBox(height: 6),
              Text(
                'Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
