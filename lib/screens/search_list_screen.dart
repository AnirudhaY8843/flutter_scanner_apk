import 'package:flutter/material.dart';

class SearchListScreen extends StatelessWidget {
  final List<dynamic> searchResults;

  SearchListScreen({super.key, required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          //search result map containing name and manufacturer
          var result = searchResults[index];
          var name = result['name'] ?? 'Unknown Name';
          var manufacturer = result['manufacturer'] ?? 'Unknown Manufacturer';
          return ListTile(
            title: Text(name),
            subtitle: Text(manufacturer),
          );
        },
      ),
    );
  }
}



// import 'package:flutter/material.dart';

// class SearchListScreen extends StatelessWidget {
//   final List<dynamic> searchResults;

//   SearchListScreen({required this.searchResults});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Search Results'),
//       ),
//       body: ListView.builder(
//         itemCount: searchResults.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text('Result ${index + 1}'),
//             subtitle: Text(searchResults[index].toString()),
//           );
//         },
//       ),
//     );
//   }
// }
