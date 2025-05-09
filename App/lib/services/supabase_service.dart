import 'package:app/models/userprofile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<UserProfile?> getUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final data = await supabase
        .from('profile_data')
        .select()
        .eq('id', user.id)
        .single();

    return UserProfile.fromJson(data);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> updatePoint(int delta) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.rpc('update_point', params: {
      'user_id': user.id,
      'delta': delta,
    });
  }

  Future<void> makeReservation(String time, String room) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('reservations').insert({
      'user_id': user.id,
      'time': time,
      'room': room,
    });
  }
}
