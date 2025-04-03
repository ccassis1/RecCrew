import 'package:flutter/material.dart';

enum ExploreViewType { map, list }

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  ExploreViewType _viewType = ExploreViewType.list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore City'),
        actions: [
          IconButton(
            icon: Icon(_viewType == ExploreViewType.map ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _viewType = _viewType == ExploreViewType.map
                    ? ExploreViewType.list
                    : ExploreViewType.map;
              });
            },
          )
        ],
      ),
      body: _viewType == ExploreViewType.map
          ? const Center(child: Text('Map View coming soon...'))
          : const RecommendationListView(),
    );
  }
}
