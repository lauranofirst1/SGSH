import 'package:app/models/business.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('business_data').select().eq('id', 1).single();
  print(response);
}
