import 'package:flutter/material.dart';

import '../models/collection_model.dart';
import 'error_view.dart';

/// Every repository-backed screen uses the same loading/error/data precedence.
class DataView extends StatelessWidget {
  const DataView({
    super.key,
    required this.models,
    required this.onRetry,
    required this.builder,
  });
  final List<CollectionModel<Object?>> models;
  final VoidCallback onRetry;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    if (models.any((model) => model.isLoading)) {
      return const Center(child: CircularProgressIndicator());
    }
    for (final model in models) {
      if (model.error != null) {
        return ErrorView(message: model.error!, onRetry: onRetry);
      }
    }
    return builder(context);
  }
}
