import 'package:flutter/material.dart';
import 'package:app/data/like_dummy.dart';

class LikesPage extends StatefulWidget {
  @override
  _LikesPageState createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('좋아요 목록'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          tabs: [
            Tab(text: '좋아요한 가게'),
            Tab(text: '좋아요한 이벤트'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildLikedStores(),
          buildLikedEvents(),
        ],
      ),
    );
  }

  Widget buildLikedStores() {
    final likedStores = dummyLikes.where((like) => like.type == true).toList();
    return ListView.builder(
      itemCount: likedStores.length,
      itemBuilder: (context, index) {
        final store = likedStores[index];
        return ListTile(
          leading: Icon(Icons.store, color: Colors.red),
          title: Text(store.user, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('방문 시간: ${store.time}'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        );
      },
    );
  }

  Widget buildLikedEvents() {
    final likedEvents = dummyLikes.where((like) => like.type == false).toList();
    return ListView.builder(
      itemCount: likedEvents.length,
      itemBuilder: (context, index) {
        final event = likedEvents[index];
        return ListTile(
          leading: Icon(Icons.event, color: Colors.blue),
          title: Text(event.user, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('참여 시간: ${event.time}'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        );
      },
    );
  }
}