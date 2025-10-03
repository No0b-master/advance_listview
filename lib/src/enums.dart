/// Load mode for pagination
enum LoadMode {
  /// Automatically load more items when scrolling near the bottom
  auto,

  /// Load more items when user taps a button
  button,
}

/// Response format from API
enum ResponseFormat {
  /// Direct array response: [...]
  direct,

  /// Wrapped response: {status: true, data: [...]}
  wrapped,
}