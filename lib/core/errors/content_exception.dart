/// Thrown when bundled content fails to load or violates a validation rule
/// (documentation plan §17.5, NFR-09 Content Integrity). Screens catch this and
/// show a plain-language error state rather than crashing or hanging.
class ContentException implements Exception {
  const ContentException(this.message, {this.source});

  /// Human-readable explanation of what went wrong.
  final String message;

  /// The content file or asset the problem relates to, when known.
  final String? source;

  @override
  String toString() =>
      'ContentException: $message${source == null ? '' : ' (source: $source)'}';
}
