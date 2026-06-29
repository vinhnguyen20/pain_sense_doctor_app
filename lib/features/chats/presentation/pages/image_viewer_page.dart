import 'package:flutter/material.dart';

class ImageViewerArgs {
  final List<String> urls;
  final int initialIndex;
  final String messageId;

  const ImageViewerArgs({
    required this.urls,
    required this.initialIndex,
    required this.messageId,
  });
}

class ImageViewerPage extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  final String messageId;

  const ImageViewerPage({
    super.key,
    required this.urls,
    required this.initialIndex,
    required this.messageId,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              Colors.white.withOpacity(0.15),
            ),
            shape: WidgetStateProperty.all(const CircleBorder()),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: widget.urls.length > 1
            ? Text('${_index + 1}/${widget.urls.length}')
            : null,
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) {
          return Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Hero(
                tag: 'chat_image_${widget.messageId}_$i',
                child: Image.network(widget.urls[i], fit: BoxFit.contain),
              ),
            ),
          );
        },
      ),
    );
  }
}
