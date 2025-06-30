import 'dart:convert';
import 'dart:io';

import 'package:common/model/device.dart';
import 'package:common/model/file_type.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/model/cross_file.dart';
import 'package:localsend_app/provider/network/send_provider.dart';
import 'package:localsend_app/provider/receive_history_provider.dart';
import 'package:localsend_app/provider/selection/selected_sending_files_provider.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:file_picker/file_picker.dart'; // For file selection
import 'package:localsend_app/provider/device_info_provider.dart'; // Import deviceInfoProvider
import 'package:path/path.dart' as p; // For path operations
import 'package:localsend_app/util/file_type_ext.dart'; // Import file_type_ext.dart for .icon
import 'package:localsend_app/util/native/open_file.dart'; // Import openFile

extension on String {
  FileType guessFileType() {
    final ext = p.extension(this).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
      case '.webp':
        return FileType.image;
      case '.mp4':
      case '.mov':
      case '.avi':
      case '.mkv':
        return FileType.video;
      case '.pdf':
        return FileType.pdf;
      case '.txt':
      case '.md':
      case '.json':
      case '.xml':
      case '.html':
      case '.css':
      case '.js':
      case '.dart':
        return FileType.text;
      case '.apk':
        return FileType.apk;
      default:
        return FileType.other;
    }
  }
}

class ChatPage extends ConsumerStatefulWidget {
  final Device device;

  const ChatPage({required this.device, super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    _messageController.clear();
    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    final CrossFile messageFile = CrossFile(
      name: 'message.txt', // A dummy name for the message file
      size: text.length,
      fileType: FileType.text,
      bytes: utf8.encode(text),
      path: null, // No actual path for a text message
      thumbnail: null,
      asset: null,
      lastModified: null,
      lastAccessed: null,
    );

    await ref.read(sendProvider).startSession(
          target: widget.device,
          files: [messageFile],
          background: true, // Send in background
        );
  }

  void _sendFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withReadStream: true, // Important for large files
      withData: !checkPlatformIs
          ([TargetPlatform.windows, TargetPlatform.linux, TargetPlatform.macOS]), // Read bytes for mobile
    );

    if (result != null && result.files.isNotEmpty) {
      final files = result.files.map((f) {
        return CrossFile(
          name: f.name,
          size: f.size,
          fileType: f.name.guessFileType(), // Assuming a utility to guess file type
          path: f.path,
          bytes: f.bytes,
          thumbnail: null, // You might generate thumbnails for images/videos
          asset: null,
          lastModified: null,
          lastAccessed: null,
        );
      }).toList();

      await ref.read(sendProvider).startSession(
            target: widget.device,
            files: files,
            background: false, // Show progress for files
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(receiveHistoryProvider);
    final currentDeviceAlias = ref.read(deviceInfoProvider).alias;

    final relevantHistory = history.entries
        .where((entry) =>
            (entry.senderAlias == widget.device.alias && !entry.isMessage) || // Received files from this device
            (entry.senderAlias == currentDeviceAlias && entry.isMessage) || // Sent messages from me
            (entry.senderAlias == widget.device.alias && entry.isMessage) // Received messages from this device
        )
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Sort by timestamp

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.alias),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: relevantHistory.length,
              itemBuilder: (context, index) {
                final entry = relevantHistory[index];
                final isMe = entry.senderAlias == currentDeviceAlias; // Determine if sent by me

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: entry.isMessage
                        ? Text(entry.fileName) // For text messages, fileName is the message content
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(entry.fileType.icon), // File icon based on type
                              Text(entry.fileName),
                              if (entry.path != null)
                                TextButton(
                                  onPressed: () {
                                    openFile(context, entry.fileType, entry.path!);
                                  },
                                  child: Text('Open File'),
                                ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _sendFiles,
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
