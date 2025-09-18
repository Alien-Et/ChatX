import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chatx/provider/logging/http_logs_provider.dart';
import 'package:chatx/widget/copyable_text.dart';
import 'package:chatx/widget/custom_basic_appbar.dart';
import 'package:chatx/widget/responsive_list_view.dart';
import 'package:refena_flutter/refena_flutter.dart';

final _dateFormat = DateFormat.Hms();

class HttpLogsPage extends StatelessWidget {
  const HttpLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = context.ref.watch(httpLogsProvider);
    return Scaffold(
      appBar: basicChatXAppbar('HTTP Logs'),
      body: ResponsiveListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () => context.ref.notifier(httpLogsProvider).clear(),
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...logs.map((log) => CopyableText(
                prefix: TextSpan(
                  text: '[${_dateFormat.format(log.timestamp)}] ',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                name: log.log,
                value: log.log,
              )),
        ],
      ),
    );
  }
}
