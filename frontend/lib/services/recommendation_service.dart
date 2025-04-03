import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recommendation.dart';

class RecommendationService {
  final _client = Supabase.instance.client;

  Future<List<Recommendation>> fetchNearbyRecommendations(String city) async {
    final response = await _client
        .from('recommendations')
        .select('*, profiles(airline)')
        .eq('city', city)
        .order('rating', ascending: false)
        .limit(25);

    if (response == null) return [];

    return (response as List<dynamic>)
        .map((json) => Recommendation.fromJson({
              ...json,
              'airline': json['profiles']?['airline'],
            }))
        .toList();
  }
}
