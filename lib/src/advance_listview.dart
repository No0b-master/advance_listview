import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'enums.dart';
import 'exceptions.dart';

/// A powerful and flexible paginated ListView widget with built-in search,
/// multiple load modes, and robust error handling.
class AdvanceListView extends StatefulWidget {
  /// API endpoint URL
  final String endpoint;

  /// HTTP method (GET or POST)
  final String method;

  /// Additional parameters to send with the request
  final Map<String, dynamic>? params;

  /// Number of items to fetch per page
  final int pageSize;

  /// Builder function for each list item
  final Widget Function(Map<String, dynamic> item) itemBuilder;

  /// Callback when an item is tapped
  final Function(Map<String, dynamic> item)? onTap;

  /// Error callback with typed exception
  final Function(AdvanceListViewException error)? onError;

  /// Enable or disable search functionality
  final bool enableSearch;

  /// Bearer token for authentication
  final String? bearerToken;

  /// Additional HTTP headers
  final Map<String, String>? extraHeaders;

  /// Pagination load mode (auto or button)
  final LoadMode loadMode;

  /// Custom load more button builder
  final Widget Function(VoidCallback onPressed, bool isLoading)?
      loadMoreButtonBuilder;

  /// API response format (direct array or wrapped object)
  final ResponseFormat responseFormat;

  /// Key for data in wrapped response (default: "data")
  final String dataKey;

  /// Key for status in wrapped response (default: "status")
  final String statusKey;

  /// Whether to throw errors instead of just calling onError
  final bool throwErrors;

  const AdvanceListView({
    super.key,
    required this.endpoint,
    this.method = "GET",
    this.params,
    required this.pageSize,
    required this.itemBuilder,
    this.onTap,
    this.onError,
    this.enableSearch = true,
    this.bearerToken,
    this.extraHeaders,
    this.loadMode = LoadMode.auto,
    this.loadMoreButtonBuilder,
    this.responseFormat = ResponseFormat.wrapped,
    this.dataKey = "data",
    this.statusKey = "status",
    this.throwErrors = false,
  });

  @override
  State<AdvanceListView> createState() => _AdvanceListViewState();
}

class _AdvanceListViewState extends State<AdvanceListView> {
  final List<Map<String, dynamic>> _items = [];
  final List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final ScrollController _controller = ScrollController();
  String _searchQuery = "";
  AdvanceListViewException? lastError;

  @override
  void initState() {
    super.initState();
    _fetchData();

    if (widget.loadMode == LoadMode.auto) {
      _controller.addListener(() {
        if (_controller.position.pixels >=
                _controller.position.maxScrollExtent - 100 &&
            !_isLoading &&
            _hasMore) {
          _fetchData();
        }
      });
    }
  }

  Future<void> _fetchData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      lastError = null;
    });

    try {
      Uri uri = Uri.parse(widget.endpoint);

      Map<String, dynamic> requestParams = {
        "page": _page,
        "limit": widget.pageSize,
        ...?widget.params,
      };

      final headers = {
        "Content-Type": "application/json",
        if (widget.bearerToken != null && widget.bearerToken!.isNotEmpty)
          "Authorization": "Bearer ${widget.bearerToken!}",
        ...?widget.extraHeaders,
      };

      http.Response response;

      try {
        if (widget.method.toUpperCase() == "POST") {
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(requestParams),
          );
        } else {
          uri = uri.replace(
            queryParameters:
                requestParams.map((k, v) => MapEntry(k, v.toString())),
          );
          response = await http.get(uri, headers: headers);
        }
      } on http.ClientException catch (e, stackTrace) {
        throw NetworkException(
          'Failed to connect to server: ${e.message}',
          originalError: e,
          stackTrace: stackTrace,
        );
      } catch (e, stackTrace) {
        throw NetworkException(
          'Network request failed: $e',
          originalError: e,
          stackTrace: stackTrace,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic decoded;

        try {
          decoded = jsonDecode(response.body);
        } on FormatException catch (e, stackTrace) {
          throw JsonParsingException(
            'Failed to parse JSON response: ${e.message}',
            originalError: e,
            stackTrace: stackTrace,
          );
        }

        List<Map<String, dynamic>> data;

        // Handle different response formats
        if (widget.responseFormat == ResponseFormat.wrapped) {
          // Validate wrapped response format
          if (decoded is! Map<String, dynamic>) {
            throw InvalidResponseFormatException(
              'Object with "${widget.statusKey}" and "${widget.dataKey}" keys',
              decoded.runtimeType.toString(),
              message:
                  'Expected response to be an object, but got ${decoded.runtimeType}',
            );
          }

          // Check if status key exists
          if (!decoded.containsKey(widget.statusKey)) {
            throw InvalidResponseFormatException(
              'Object with "${widget.statusKey}" key',
              'Object without "${widget.statusKey}" key',
              message:
                  'Response missing required "${widget.statusKey}" key. Available keys: ${decoded.keys.join(", ")}',
            );
          }

          // Validate status value
          final status = decoded[widget.statusKey];
          if (status != true && status != 1 && status != "true") {
            throw ApiException(
              response.statusCode,
              decoded,
              message:
                  'API returned unsuccessful status: ${widget.statusKey} = $status',
            );
          }

          // Check if data key exists
          if (!decoded.containsKey(widget.dataKey)) {
            throw InvalidResponseFormatException(
              'Object with "${widget.dataKey}" key',
              'Object without "${widget.dataKey}" key',
              message:
                  'Response missing required "${widget.dataKey}" key. Available keys: ${decoded.keys.join(", ")}',
            );
          }

          // Validate data is a List
          final rawData = decoded[widget.dataKey];
          if (rawData is! List) {
            throw InvalidResponseFormatException(
              'Array',
              rawData.runtimeType.toString(),
              message:
                  '"${widget.dataKey}" must be an array, but got ${rawData.runtimeType}',
            );
          }

          // Cast to List<Map<String, dynamic>>
          try {
            data = List<Map<String, dynamic>>.from(
              rawData.map((item) {
                if (item is Map<String, dynamic>) {
                  return item;
                } else if (item is Map) {
                  return Map<String, dynamic>.from(item);
                } else {
                  throw InvalidResponseFormatException(
                    'Array of objects',
                    'Array containing ${item.runtimeType}',
                    message:
                        '"${widget.dataKey}" must contain only objects, but found ${item.runtimeType}',
                  );
                }
              }),
            );
          } catch (e) {
            if (e is InvalidResponseFormatException) rethrow;
            throw InvalidResponseFormatException(
              'Array of objects',
              'Array with invalid items',
              message: '"${widget.dataKey}" contains invalid items: $e',
              originalError: e,
            );
          }
        } else {
          // Direct response format (legacy support)
          if (decoded is! List) {
            throw InvalidResponseFormatException(
              'Array',
              decoded.runtimeType.toString(),
              message:
                  'Expected response to be an array, but got ${decoded.runtimeType}',
            );
          }

          try {
            data = List<Map<String, dynamic>>.from(
              decoded.map((item) {
                if (item is Map<String, dynamic>) {
                  return item;
                } else if (item is Map) {
                  return Map<String, dynamic>.from(item);
                } else {
                  throw InvalidResponseFormatException(
                    'Array of objects',
                    'Array containing ${item.runtimeType}',
                    message:
                        'Response array must contain only objects, but found ${item.runtimeType}',
                  );
                }
              }),
            );
          } catch (e) {
            if (e is InvalidResponseFormatException) rethrow;
            throw InvalidResponseFormatException(
              'Array of objects',
              'Array with invalid items',
              message: 'Response array contains invalid items: $e',
              originalError: e,
            );
          }
        }

        // Process the data
        setState(() {
          _page++;
          _items.addAll(data);
          _applySearch(_searchQuery);
          if (data.length < widget.pageSize) _hasMore = false;
        });

        // ✅ Auto fill for large screens
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_controller.hasClients &&
              _controller.position.maxScrollExtent <=
                  _controller.position.viewportDimension &&
              _hasMore) {
            _fetchData(); // fetch until fills viewport
          }
        });
      } else {
        // Handle error responses
        dynamic errorBody;
        String errorMessage =
            'Request failed with status ${response.statusCode}';

        try {
          errorBody = jsonDecode(response.body);
          if (errorBody is Map) {
            errorMessage = errorBody['message']?.toString() ??
                errorBody['error']?.toString() ??
                errorMessage;
          }
        } catch (_) {
          errorBody = response.body;
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }

        throw ApiException(
          response.statusCode,
          errorBody,
          message: errorMessage,
        );
      }
    } on AdvanceListViewException catch (e) {
      _handleError(e);
      if (widget.throwErrors) rethrow;
    } catch (e, stackTrace) {
      final exception = AdvanceListViewException(
        'Unexpected error: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
      _handleError(exception);
      if (widget.throwErrors) throw exception;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applySearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredItems
          ..clear()
          ..addAll(_items);
      } else {
        _filteredItems
          ..clear()
          ..addAll(_items.where((item) {
            return item.values.any((value) =>
                value.toString().toLowerCase().contains(_searchQuery));
          }));
      }
    });
  }

  void _handleError(AdvanceListViewException exception) {
    setState(() {
      lastError = exception;
    });
    debugPrint(exception.toString());
    widget.onError?.call(exception);
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredItems;

    return Column(
      children: [
        if (widget.enableSearch)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _applySearch,
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: widget.loadMode == LoadMode.auto ? _controller : null,
            itemCount: displayList.length +
                (widget.loadMode == LoadMode.auto && (_isLoading || _hasMore)
                    ? 1
                    : 0),
            itemBuilder: (context, index) {
              if (index < displayList.length) {
                final item = displayList[index];
                return GestureDetector(
                  onTap: () => widget.onTap?.call(item),
                  child: widget.itemBuilder(item),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
        if (widget.loadMode == LoadMode.button && _hasMore)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: widget.loadMoreButtonBuilder != null
                ? widget.loadMoreButtonBuilder!(_fetchData, _isLoading)
                : ElevatedButton(
                    onPressed: _isLoading ? null : _fetchData,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Load More"),
                  ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
