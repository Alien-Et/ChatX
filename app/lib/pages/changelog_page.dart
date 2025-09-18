import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:chatx/gen/assets.gen.dart';
import 'package:chatx/gen/strings.g.dart';
import 'package:chatx/util/ui/nav_bar_padding.dart';
import 'package:chatx/widget/custom_basic_appbar.dart';

class ChangelogPage extends StatelessWidget {
  const ChangelogPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: basicChatXAppbar(t.changelogPage.title),
      body: FutureBuilder(
        future: rootBundle.loadString(Assets.changelog), // ignore: discarded_futures
        builder: (context, data) {
          if (!data.hasData) {
            return Container();
          }
          return Markdown(
            padding: EdgeInsets.only(
              left: 15 + MediaQuery.of(context).padding.left,
              right: 15 + MediaQuery.of(context).padding.right,
              top: 15,
              bottom: 15 + getNavBarPadding(context),
            ),
            data: data.data!,
          );
        },
      ),
    );
  }
}
