// lib/core/models/search_params.dart
import 'package:flutter/foundation.dart';

@immutable
class SearchParams {
  final String routeId;
  final String dateString; // Changed from DateTime to String

  const SearchParams({required this.routeId, required this.dateString});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchParams &&
        other.routeId == routeId &&
        other.dateString == dateString;
  }

  @override
  int get hashCode => routeId.hashCode ^ dateString.hashCode;
}
