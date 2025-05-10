import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatelessWidget {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF8),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 상단 로고 이미지
                Image.asset(
                  'assets/images/logo/sgsh_logo.png',
                  height: 300,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 10,),
                Text(
                  '나의 가치를 담은 가게를\n발견해보세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown[400],
                  ),
                ),
                const SizedBox(height: 60),

                // 카카오 로그인 버튼 (이미지 전체)
                GestureDetector(
                  onTap: () async {
                    try {
                      await supabase.auth.signInWithOAuth(
                        OAuthProvider.kakao,
                        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
                        authScreenLaunchMode: LaunchMode.externalApplication,
                      );

                      supabase.auth.onAuthStateChange.listen((data) async {
                        final event = data.event;
                        if (event == AuthChangeEvent.signedIn) {
                          final user = supabase.auth.currentUser;
                          if (user != null) {
                            final existing = await supabase
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
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('로그인 오류: $e')),
                      );
                    }
                  },
                  child: Image.asset(
                    'assets/images/logo/kakao_login.png',
                    width: double.infinity,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
