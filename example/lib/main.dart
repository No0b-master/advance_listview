import 'package:flutter/material.dart';
import 'package:advance_listview/advance_listview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdvanceListView Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AdvanceListView Examples'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Auto Load'),
              Tab(text: 'Button Load'),
              Tab(text: 'With Search'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AutoLoadExample(),
            ButtonLoadExample(),
            SearchExample(),
          ],
        ),
      ),
    );
  }
}

class AutoLoadExample extends StatelessWidget {
  const AutoLoadExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AdvanceListView(
      endpoint: "https://jsonplaceholder.typicode.com/posts",
      pageSize: 10,
      responseFormat: ResponseFormat.direct,
      enableSearch: false,
      loadMode: LoadMode.auto,
      itemBuilder: (item) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            child: Text(item['id'].toString()),
          ),
          title: Text(
            item['title'] ?? 'No Title',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            item['body'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      onTap: (item) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(item['title'] ?? 'No Title'),
            content: Text(item['body'] ?? 'No Content'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }
}

class ButtonLoadExample extends StatelessWidget {
  const ButtonLoadExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AdvanceListView(
      endpoint: "https://jsonplaceholder.typicode.com/users",
      pageSize: 5,
      responseFormat: ResponseFormat.direct,
      enableSearch: false,
      loadMode: LoadMode.button,
      itemBuilder: (item) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              item['name']?[0] ?? '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(item['name'] ?? 'Unknown'),
          subtitle: Text(item['email'] ?? ''),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      },
    );
  }
}

class SearchExample extends StatelessWidget {
  const SearchExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AdvanceListView(
      endpoint: "https://jsonplaceholder.typicode.com/comments",
      pageSize: 20,
      responseFormat: ResponseFormat.direct,
      enableSearch: true,
      loadMode: LoadMode.auto,
      itemBuilder: (item) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name'] ?? 'No Name',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['email'] ?? '',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['body'] ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      },
    );
  }
}
