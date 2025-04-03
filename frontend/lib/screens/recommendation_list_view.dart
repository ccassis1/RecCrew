import 'package:flutter/material.dart';

class RecommendationListView extends StatelessWidget {
  const RecommendationListView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with Supabase call to fetch nearby recommendations
    final sampleData = [
      {
        'name': 'Crew Cafe',
        'rating': 4.8,
        'distance': '0.3 mi',
        'crewDiscount': true,
        'airline': 'Delta',
      },
      {
        'name': 'Sky Bar',
        'rating': 4.5,
        'distance': '0.7 mi',
        'crewDiscount': false,
        'airline': 'United',
      },
    ];

    return ListView.builder(
      itemCount: sampleData.length,
      itemBuilder: (context, index) {
        final item = sampleData[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.place, color: Colors.indigo),
            title: Text(item['name']!),
            subtitle: Text('${item['rating']} ★  •  ${item['distance']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item['crewDiscount'] == true)
                  const Text('Crew Discount', style: TextStyle(color: Colors.green)),
                Text(item['airline']!, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}
