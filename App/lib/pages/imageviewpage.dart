import 'package:flutter/material.dart';

class ImageViewPage extends StatelessWidget {
  final String imageUrl;

  const ImageViewPage({
    super.key,
    required this.imageUrl,
  });

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '사진 보기',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: GestureDetector(
            onTap: () => _showPopup(context),
            
              child: Image.network(
                imageUrl,
                fit: BoxFit.fitWidth,
                width: MediaQuery.of(context).size.width,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey[600],
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      
    );
  }
}
