import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatelessWidget {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('로그인', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),

            GestureDetector(
              child: Text("data"),
              onTap: () async {
                final User? user = supabase.auth.currentUser;
                print(user);
              },
            ),
            ElevatedButton(
              onPressed: () async {
                final User? user = supabase.auth.currentUser;
                print(user);
                try {
                  await supabase.auth.signInWithOAuth(
                    OAuthProvider.kakao,
                    redirectTo:
                        'io.supabase.flutterquickstart://login-callback/',
                    authScreenLaunchMode: LaunchMode.externalApplication,
                  );
                  supabase.auth.onAuthStateChange.listen((data) async {
                    final event = data.event;
                    if (event == AuthChangeEvent.signedIn) {
                      final user = supabase.auth.currentUser;
                      if (user != null) {
                        print('✅ 로그인 성공: ${user.email ?? user.id}');

                        final existing =
                            await supabase
                                .from('profile_data')
                                .select()
                                .eq('id', user.id)
                                .maybeSingle();

                        if (existing == null) {
                          await supabase.from('profile_data').insert({
                            'id': user.id,
                            'email': user.email,
                            'point': 0,
                          });
                        }

                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => MyApp()),
                          );
                        }
                      }
                    }
                  });
                } on AuthException catch (error) {
                  print(error);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('로그인 오류: $e')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
              ),
              child: const Text("카카오 로그인"),
            ),
          ],
        ),
      ),
    );
  }
}
