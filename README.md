# advance_listview

[![pub package](https://img.shields.io/pub/v/advance_listview.svg)](https://pub.dev/packages/advance_listview)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue.svg)](https://flutter.dev)

A powerful and flexible paginated ListView widget for Flutter that simplifies API integration with built-in pagination, search functionality, and comprehensive error handling.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
- [Usage Examples](#usage-examples)
- [API Reference](#api-reference)
- [Error Handling](#error-handling)
- [API Response Format](#api-response-format)
- [Advanced Configuration](#advanced-configuration)
- [Example Application](#example-application)
- [Contributing](#contributing)
- [Author](#author)
- [License](#license)

## Overview

`advance_listview` is a production-ready Flutter widget that eliminates the boilerplate code required for implementing paginated lists. It handles API requests, pagination logic, search functionality, and error states out of the box, allowing you to focus on building your UI.

### What Problems Does It Solve?

**Without advance_listview**, implementing a paginated list requires:
- Writing pagination logic manually
- Managing loading states
- Implementing scroll listeners
- Handling API errors
- Building search functionality
- Managing data filtering
- Handling different API response formats

**With advance_listview**, all of this is handled automatically with a single widget.

## Features

**Pagination**
- Automatic pagination on scroll
- Button-based pagination option
- Configurable page size
- Smart viewport filling on large screens

**Search & Filtering**
- Built-in search functionality
- Real-time filtering across all data fields
- Optional search bar

**Flexibility**
- Support for GET and POST requests
- Custom HTTP headers
- Bearer token authentication
- Multiple API response format support
- Custom item builders
- Custom load more button builder

**Error Handling**
- Comprehensive exception hierarchy
- Typed error callbacks
- Automatic error recovery
- Detailed error messages

**Developer Experience**
- Type-safe API
- Extensive documentation
- Working examples
- Clear error messages

## Installation

Add `advance_listview` to your `pubspec.yaml`:

```yaml
dependencies:
  advance_listview: ^1.0.0
```

Install the package:

```bash
flutter pub get
```

Import in your Dart code:

```dart
import 'package:advance_listview/advance_listview.dart';
```

## Quick Start

Here's a minimal example to get you started:

```dart
import 'package:flutter/material.dart';
import 'package:advance_listview/advance_listview.dart';

class UsersListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: AdvanceListView(
        endpoint: "https://api.example.com/users",
        pageSize: 20,
        itemBuilder: (item) => ListTile(
          title: Text(item['name']),
          subtitle: Text(item['email']),
        ),
      ),
    );
  }
}
```

That's it! The widget automatically handles:
- Fetching data from the API
- Pagination as you scroll
- Loading indicators
- Error handling
- Search functionality

## How It Works

### 1. Initial Load
When the widget is first created, it makes an API request to your endpoint with pagination parameters:

```
GET https://api.example.com/users?page=1&limit=20
```

### 2. Automatic Pagination
As you scroll near the bottom of the list (within 100 pixels), the widget automatically fetches the next page:

```
GET https://api.example.com/users?page=2&limit=20
```

### 3. Data Processing
The widget expects your API to return data in one of two formats:

**Wrapped Format (Default)**
```json
{
  "status": true,
  "data": [
    {"id": 1, "name": "John Doe", "email": "john@example.com"},
    {"id": 2, "name": "Jane Smith", "email": "jane@example.com"}
  ]
}
```

**Direct Format**
```json
[
  {"id": 1, "name": "John Doe", "email": "john@example.com"},
  {"id": 2, "name": "Jane Smith", "email": "jane@example.com"}
]
```

### 4. Search Functionality
When enabled, the search bar filters the already loaded data in real-time. The search is performed across all fields in each item.

### 5. Error Handling
If any error occurs (network failure, invalid response, API error), the widget:
- Stops loading
- Calls your error callback (if provided)
- Logs the error to console
- Optionally throws typed exceptions

## Usage Examples

### Basic Usage with Wrapped Response

```dart
AdvanceListView(
  endpoint: "https://api.example.com/users",
  pageSize: 20,
  responseFormat: ResponseFormat.wrapped,
  itemBuilder: (item) => Card(
    margin: EdgeInsets.all(8),
    child: ListTile(
      leading: CircleAvatar(
        child: Text(item['name'][0]),
      ),
      title: Text(item['name']),
      subtitle: Text(item['email']),
    ),
  ),
)
```

### With Authentication

```dart
AdvanceListView(
  endpoint: "https://api.example.com/users",
  pageSize: 20,
  bearerToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  extraHeaders: {
    "X-API-Key": "your-api-key",
    "X-App-Version": "1.0.0",
  },
  itemBuilder: (item) => ListTile(
    title: Text(item['name']),
  ),
)
```

### Button Load Mode

Instead of automatic pagination, users can tap a button to load more:

```dart
AdvanceListView(
  endpoint: "https://api.example.com/users",
  pageSize: 20,
  loadMode: LoadMode.button,
  itemBuilder: (item) => ListTile(
    title: Text(item['name']),
  ),
)
```

### Custom Load More Button

```dart
AdvanceListView(
  endpoint: "https://api.example.com/users",
  pageSize: 20,
  loadMode: LoadMode.button,
  loadMoreButtonBuilder: (onPressed, isLoading) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.refresh),
        label: Text(isLoading ? 'Loading...' : 'Load More Items'),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 48),
        ),
      ),
    );
  },
  itemBuilder: (item) => ListTile(
    title: Text(item['name']),
  ),
)
```

### POST Request with Parameters

```dart
AdvanceListView(
  endpoint: "https://api.example.com/users/search",
  method: "POST",
  params: {
    "filters": {
      "status": "active",
      "role": "admin",
      "department": "engineering",
    },
    "sort_by": "created_at",
    "order": "desc",
  },
  pageSize: 20,
  itemBuilder: (item) => ListTile(
    title: Text(item['name']),
  ),
)
```

### With Item Tap Handler

```dart
AdvanceListView(
  endpoint: "https://api.example.com/products",
  pageSize: 20,
  itemBuilder: (item) => Card(
    child: ListTile(
      title: Text(item['name']),
      subtitle: Text('\$${item['price']}'),
      trailing: Icon(Icons.chevron_right),
    ),
  ),
  onTap: (item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          productId: item['id'],
        ),
      ),
    );
  },
)
```

### Comprehensive Error Handling

```dart
AdvanceListView(
  endpoint: "https://api.example.com/users",
  pageSize: 20,
  itemBuilder: (item) => ListTile(
    title: Text(item['name']),
  ),
  onError: (error) {
    // Handle different error types
    String message;
    Color color;
    
    if (error is ApiException) {
      message = 'Server error: ${error.statusCode}';
      color = Colors.red;
    } else if (error is NetworkException) {
      message = 'Network error: Please check your connection';
      color = Colors.orange;
    } else if (error is InvalidResponseFormatException) {
      message = 'Invalid data format received';
      color = Colors.purple;
    } else if (error is JsonParsingException) {
      message = 'Failed to parse response';
      color = Colors.pink;
    } else {
      message = error.message;
      color = Colors.grey;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            // Trigger reload by rebuilding the widget
          },
        ),
      ),
    );
  },
)
```

### Without Search

```dart
AdvanceListView(
  endpoint: "https://api.example.com/users",
  pageSize: 20,
  enableSearch: false,
  itemBuilder: (item) => ListTile(
    title: Text(item['name']),
  ),
)
```

### Direct Array Response Format

```dart
AdvanceListView(
  endpoint: "https://jsonplaceholder.typicode.com/users",
  pageSize: 10,
  responseFormat: ResponseFormat.direct,
  itemBuilder: (item) => ListTile(
    title: Text(item['name']),
  ),
)
```

### Custom Data and Status Keys

If your API uses different keys for status and data:

```dart
// API Response: {"success": true, "results": [...]}
AdvanceListView(
  endpoint: "https://api.example.com/users",
  pageSize: 20,
  responseFormat: ResponseFormat.wrapped,
  statusKey: "success",
  dataKey: "results",
  itemBuilder: (item) => ListTile(
    title: Text(item['name']),
  ),
)
```

## API Reference

### AdvanceListView Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `endpoint` | `String` | Yes | - | The API endpoint URL |
| `pageSize` | `int` | Yes | - | Number of items to fetch per page |
| `itemBuilder` | `Widget Function(Map<String, dynamic>)` | Yes | - | Builder function for each list item |
| `method` | `String` | No | `"GET"` | HTTP method (GET or POST) |
| `params` | `Map<String, dynamic>?` | No | `null` | Additional parameters to send with requests |
| `onTap` | `Function(Map<String, dynamic>)?` | No | `null` | Callback when an item is tapped |
| `onError` | `Function(AdvanceListViewException)?` | No | `null` | Callback when an error occurs |
| `enableSearch` | `bool` | No | `true` | Enable/disable search functionality |
| `bearerToken` | `String?` | No | `null` | Bearer token for authentication |
| `extraHeaders` | `Map<String, String>?` | No | `null` | Additional HTTP headers |
| `loadMode` | `LoadMode` | No | `LoadMode.auto` | Pagination mode (auto or button) |
| `loadMoreButtonBuilder` | `Widget Function(VoidCallback, bool)?` | No | `null` | Custom load more button builder |
| `responseFormat` | `ResponseFormat` | No | `ResponseFormat.wrapped` | API response format |
| `dataKey` | `String` | No | `"data"` | Key for data array in wrapped response |
| `statusKey` | `String` | No | `"status"` | Key for status field in wrapped response |
| `throwErrors` | `bool` | No | `false` | Whether to throw exceptions or just call onError |

### Enums

#### LoadMode

```dart
enum LoadMode {
  auto,    // Automatically load more when scrolling near bottom
  button,  // Load more when button is tapped
}
```

#### ResponseFormat

```dart
enum ResponseFormat {
  direct,   // Direct array: [...]
  wrapped,  // Wrapped object: {status: true, data: [...]}
}
```

## Error Handling

The package provides a comprehensive exception hierarchy for better error handling:

### Exception Types

#### AdvanceListViewException
Base exception class that all other exceptions extend.

```dart
class AdvanceListViewException {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;
}
```

#### ApiException
Thrown when the API returns an error status code (non 200/201).

```dart
class ApiException extends AdvanceListViewException {
  final int statusCode;        // HTTP status code
  final dynamic responseBody;  // Raw response body
}
```

**Example:**
```dart
onError: (error) {
  if (error is ApiException) {
    if (error.statusCode == 401) {
      // Handle unauthorized
      Navigator.pushReplacementNamed(context, '/login');
    } else if (error.statusCode >= 500) {
      // Handle server errors
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Server Error'),
          content: Text('The server is experiencing issues. Please try again later.'),
        ),
      );
    }
  }
}
```

#### NetworkException
Thrown when network request fails (connection issues, timeout, etc).

```dart
class NetworkException extends AdvanceListViewException {
  // Includes network error details
}
```

**Example:**
```dart
onError: (error) {
  if (error is NetworkException) {
    // Show retry option
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connection Error'),
        content: Text('Please check your internet connection and try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Trigger reload
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

#### InvalidResponseFormatException
Thrown when the API response doesn't match the expected format.

```dart
class InvalidResponseFormatException extends AdvanceListViewException {
  final String expectedFormat;  // What was expected
  final String actualFormat;    // What was received
}
```

**Example:**
```dart
onError: (error) {
  if (error is InvalidResponseFormatException) {
    print('Expected: ${error.expectedFormat}');
    print('Got: ${error.actualFormat}');
    // Contact backend team about format mismatch
  }
}
```

#### JsonParsingException
Thrown when JSON parsing fails.

```dart
class JsonParsingException extends AdvanceListViewException {
  // Includes parsing error details
}
```

### Error Handling Strategies

#### Strategy 1: User-Friendly Messages
```dart
onError: (error) {
  String userMessage = 'Something went wrong';
  
  if (error is NetworkException) {
    userMessage = 'Please check your internet connection';
  } else if (error is ApiException && error.statusCode == 404) {
    userMessage = 'Data not found';
  }
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(userMessage)),
  );
}
```

#### Strategy 2: Logging for Debugging
```dart
onError: (error) {
  // Log to your analytics service
  FirebaseAnalytics.instance.logEvent(
    name: 'list_load_error',
    parameters: {
      'error_type': error.runtimeType.toString(),
      'message': error.message,
      'endpoint': 'https://api.example.com/users',
    },
  );
  
  // Log to console in debug mode
  if (kDebugMode) {
    print('Error: ${error.toString()}');
    if (error.stackTrace != null) {
      print('Stack trace: ${error.stackTrace}');
    }
  }
}
```

#### Strategy 3: Throwing Exceptions
```dart
// Set throwErrors to true to catch exceptions yourself
AdvanceListView(
  endpoint: "https://api.example.com/users",
  pageSize: 20,
  throwErrors: true,
  itemBuilder: (item) => ListTile(title: Text(item['name'])),
)

// Then wrap in a try-catch or use ErrorWidget
```

## API Response Format

### Wrapped Format (Recommended)

The widget expects a JSON object with status and data fields:

```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "email": "jane@example.com"
    }
  ]
}
```

**Status Field:** Can be `true`, `1`, or `"true"` (any other value is treated as error)

**Data Field:** Must be an array of objects

**Custom Keys:** You can customize the key names:
```dart
AdvanceListView(
  statusKey: "success",
  dataKey: "results",
  // ...
)
```

### Direct Format

A JSON array of objects:

```json
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  {
    "id": 2,
    "name": "Jane Smith",
    "email": "jane@example.com"
  }
]
```

Set `responseFormat: ResponseFormat.direct` to use this format.

### Pagination

The widget automatically sends pagination parameters with each request:

**GET Request:**
```
GET https://api.example.com/users?page=1&limit=20
```

**POST Request:**
```json
{
  "page": 1,
  "limit": 20,
  "filters": {
    // your custom params
  }
}
```

Your API should:
- Accept `page` (current page number, starts at 1)
- Accept `limit` (number of items per page)
- Return exactly `limit` items when more data is available
- Return fewer than `limit` items on the last page

## Advanced Configuration

### Real-World Example: E-commerce Product List

```dart
class ProductListPage extends StatelessWidget {
  final String category;
  final String? searchQuery;
  
  const ProductListPage({
    required this.category,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: AdvanceListView(
        endpoint: "https://api.shop.com/products/search",
        method: "POST",
        params: {
          "category": category,
          if (searchQuery != null) "query": searchQuery,
          "sort": "popularity",
        },
        pageSize: 30,
        bearerToken: AuthService.instance.token,
        extraHeaders: {
          "X-Device-Id": DeviceService.instance.deviceId,
        },
        responseFormat: ResponseFormat.wrapped,
        enableSearch: true,
        itemBuilder: (product) => ProductCard(
          imageUrl: product['image_url'],
          name: product['name'],
          price: product['price'],
          rating: product['rating'],
          onAddToCart: () => CartService.instance.add(product['id']),
        ),
        onTap: (product) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(
                productId: product['id'],
              ),
            ),
          );
        },
        onError: (error) {
          if (error is ApiException && error.statusCode == 401) {
            // Token expired
            AuthService.instance.logout();
            Navigator.pushReplacementNamed(context, '/login');
          } else {
            ErrorHandler.show(context, error);
          }
        },
      ),
    );
  }
}
```

### Performance Tips

1. **Page Size**: Choose an appropriate page size (10-50 items)
    - Too small: Too many API requests
    - Too large: Slow initial load, excessive memory usage

2. **Search**: If you have thousands of items, consider server-side search
   ```dart
   // Disable built-in search
   enableSearch: false,
   
   // Implement server-side search in params
   params: {
     "search": userSearchQuery,
   }
   ```

3. **Caching**: Use the http client's cache or implement your own
   ```dart
   // The widget doesn't cache by default
   // Consider implementing cache at the API level
   ```

## Example Application

The package includes a comprehensive example application demonstrating all features:

```bash
cd example
flutter run
```

The example app includes:
- Auto-load pagination
- Button-load pagination
- Search functionality
- Error handling
- Different API formats
- Custom styling

## Contributing

Contributions are welcome and appreciated! Here's how you can contribute:

### How to Contribute

1. **Fork the Repository**
   ```bash
   # Click the 'Fork' button on GitHub
   # Then clone your fork
   git clone https://github.com/yourusername/advance_listview.git
   cd advance_listview
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make Your Changes**
    - Write clean, documented code
    - Follow Dart/Flutter style guidelines
    - Add tests for new features
    - Update documentation

4. **Test Your Changes**
   ```bash
   # Run tests
   flutter test
   
   # Run analysis
   flutter analyze
   
   # Format code
   dart format .
   
   # Test example app
   cd example
   flutter run
   ```

5. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "Add: Amazing new feature"
   ```

   Use conventional commit messages:
    - `Add:` for new features
    - `Fix:` for bug fixes
    - `Update:` for updates to existing features
    - `Remove:` for removed features
    - `Docs:` for documentation changes

6. **Push to Your Fork**
   ```bash
   git push origin feature/amazing-feature
   ```

7. **Create a Pull Request**
    - Go to the original repository on GitHub
    - Click "New Pull Request"
    - Select your fork and branch
    - Describe your changes in detail
    - Submit the PR

### Contribution Guidelines

- **Code Quality**: Follow Flutter best practices and Dart style guide
- **Documentation**: Update README and add dartdoc comments
- **Tests**: Include unit tests for new features
- **Breaking Changes**: Discuss major changes in an issue first
- **Commit Messages**: Use clear, descriptive commit messages
- **One Feature Per PR**: Keep pull requests focused

### Areas for Contribution

We're particularly interested in contributions for:
- Additional response format support
- Performance optimizations
- More customization options
- Additional example use cases
- Bug fixes and improvements
- Documentation enhancements
- Test coverage improvements

### Reporting Issues

Found a bug? Have a feature request?

1. Check if the issue already exists
2. Create a new issue with:
    - Clear title
    - Detailed description
    - Steps to reproduce (for bugs)
    - Expected vs actual behavior
    - Flutter/Dart version
    - Code samples if applicable

### Questions?

For questions about contributing, feel free to:
- Open a discussion on GitHub
- Reach out via [LinkedIn](https://www.linkedin.com/in/ahmad-mohd)

## Author

**Ahmad Mohd**

- GitHub: [@No0b-master](https://github.com/No0b-master)
- LinkedIn: [ahmad-mohd](https://www.linkedin.com/in/ahmad-mohd)
- Website: [mohd-ahmad.vercel.app](http://mohd-ahmad.vercel.app/)

## Support

If you find this package helpful, please:
- Give it a star on [GitHub](https://github.com/No0b-master/advance_listview)
- Like it on [pub.dev](https://pub.dev/packages/advance_listview)
- Share it with other Flutter developers

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Ahmad Mohd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

**Made by [Mohd Ahmad](https://github.com/No0b-master)**