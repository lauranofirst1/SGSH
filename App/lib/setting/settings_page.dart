import 'package:app/auth/loginpage.dart';
import 'package:app/setting/qna_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 항상 흰색 유지

      appBar: AppBar(
        backgroundColor: Colors.white, // 항상 흰색 유지
        elevation: 0.5,
        centerTitle: false,
        title: const Text(
          '설정',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        foregroundColor: Colors.black, // 버튼색이 스크롤에 의해 바뀌지 않도록
        surfaceTintColor: Colors.white, // 머티리얼 3 대응용 (앱바 배경 흐림 방지)
        shadowColor: Colors.transparent, // 그림자 투명화(선택)
      ),
      body: ListView(
        children: [
          _buildSectionTitle('서비스 이용'),
          _buildSettingTile(
            context,
            '문의하기',
            Icons.help_outline,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QnAPage()),
            ),
          ),
          _buildSettingTile(
            context,
            '최근 본 기록 지우기',
            Icons.history,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    '최근 본 기록 지우기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  content: const Text(
                    '최근 본 기록을 모두 지우시겠습니까?',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: 최근 본 기록 지우기 로직 구현
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('최근 본 기록이 삭제되었습니다'),
                            backgroundColor: Colors.black87,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 32),
          _buildSettingTile(
            context,
            '로그아웃',
            Icons.logout,
            () async {
              await Supabase.instance.client.auth.signOut();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('로그아웃 되었습니다'),
                  backgroundColor: Colors.black87,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            textColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color textColor = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
        ),
      ),
      trailing: title == '로그아웃'
          ? null
          : const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
      onTap: onTap,
    );
  }
}
