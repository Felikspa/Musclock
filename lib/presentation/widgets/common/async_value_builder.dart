import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

/// A reusable widget for handling AsyncValue states
/// Provides consistent loading, error, and data handling across the app
class AsyncValueBuilder<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(BuildContext, T) data;
  final Widget? loading;
  final Widget? error;
  final Widget? empty;

  const AsyncValueBuilder({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.empty,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (T value) {
        // Handle empty case if empty widget is provided
        if (empty != null && _isEmpty(value)) {
          return empty!;
        }
        return data(context, value);
      },
      loading: () => loading ?? _defaultLoading(context),
      error: (Object error, StackTrace? stackTrace) {
        return this.error ?? _defaultError(context, error);
      },
    );
  }

  bool _isEmpty(T value) {
    if (value is List) {
      return (value as List).isEmpty;
    }
    if (value is Map) {
      return (value as Map).isEmpty;
    }
    if (value is Set) {
      return (value as Set).isEmpty;
    }
    if (value is String) {
      return value.isEmpty;
    }
    return false;
  }

  Widget _defaultLoading(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: CircularProgressIndicator(
        color: AppTheme.accent,
        backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      ),
    );
  }

  Widget _defaultError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade400,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Error: $error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Convenience builder for async values with simplified callback
/// Use this when you only need the data value
class AsyncValueView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(BuildContext, T) builder;

  const AsyncValueView({
    super.key,
    required this.value,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (T data) => builder(context, data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace? stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}
