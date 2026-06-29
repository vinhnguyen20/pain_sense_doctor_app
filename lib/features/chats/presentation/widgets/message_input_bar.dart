import 'dart:io';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessageInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final void Function(XFile image, String? text)? onSendWithImages;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onSendWithImages,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _showAttachmentOptions() async {
    if (widget.onSendWithImages == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Send attachment', style: context.titleMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  _AttachmentOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    color: context.chatColors.attachmentGallery,
                    onTap: () async {
                      Navigator.pop(context);
                      final image = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                        maxWidth: 1080,
                        maxHeight: 1080,
                      );
                      if (image != null) setState(() => _selectedImage = image);
                    },
                  ),
                  const SizedBox(width: 16),
                  _AttachmentOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    color: context.chatColors.attachmentCamera,
                    onTap: () async {
                      Navigator.pop(context);
                      final image = await _picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                        maxWidth: 1080,
                        maxHeight: 1080,
                      );
                      if (image != null) setState(() => _selectedImage = image);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSend() {
    if (_selectedImage != null && widget.onSendWithImages != null) {
      final text = widget.controller.text.trim();
      widget.onSendWithImages?.call(
        _selectedImage!,
        text.isEmpty ? null : text,
      );
      setState(() => _selectedImage = null);
      widget.controller.clear();
    } else {
      widget.onSend();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        boxShadow: [
          BoxShadow(
            color: context.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedImage!.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.chatColors.imageOverlay,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: context.surface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: context.onSurface.withValues(alpha: 0.1),
                  radius: 24,
                  child: IconButton(
                    onPressed: widget.onSendWithImages == null
                        ? null
                        : _showAttachmentOptions,
                    icon: Icon(Icons.add, color: context.primary, size: 22),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: context.onSurface.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      decoration: InputDecoration(
                        filled: false,
                        hintText: _selectedImage != null
                            ? 'Add a caption...'
                            : 'Type your message...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintStyle: context.bodyMedium?.copyWith(
                          color: context.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: context.primary,
                  radius: 24,
                  child: IconButton(
                    onPressed: _handleSend,
                    icon: Icon(Icons.send, color: context.onPrimary, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: context.labelSmall),
        ],
      ),
    );
  }
}
