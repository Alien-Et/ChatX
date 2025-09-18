import 'package:common/isolate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chatx/config/init.dart';
import 'package:chatx/config/init_error.dart';
import 'package:chatx/config/theme.dart';
import 'package:chatx/gen/strings.g.dart';
import 'package:chatx/model/persistence/color_mode.dart';
import 'package:chatx/pages/home_page.dart';
import 'package:chatx/provider/local_ip_provider.dart';
import 'package:chatx/provider/settings_provider.dart';
import 'package:chatx/util/ui/dynamic_colors.dart';
import 'package:chatx/widget/watcher/life_cycle_watcher.dart';
import 'package:chatx/widget/watcher/shortcut_watcher.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

// 条件导入平台特定的组件
import 'package:chatx/widget/watcher/tray_watcher.dart' if (dart.library.html) 'package:chatx/widget/watcher/tray_watcher_web.dart';
import 'package:chatx/widget/watcher/window_watcher.dart' if (dart.library.html) 'package:chatx/widget/watcher/window_watcher_web.dart';

Future<void> main(List<String> args) async {
  final RefenaContainer container;
  try {
    container = await preInit(args);
  } catch (e, stackTrace) {
    showInitErrorApp(
      error: e,
      stackTrace: stackTrace,
    );
    return;
  }

  runApp(RefenaScope.withContainer(
    container: container,
    child: TranslationProvider(
      child: const ChatXApp(),
    ),
  ));
}

class ChatXApp extends StatelessWidget {
  const ChatXApp();

  @override
  Widget build(BuildContext context) {
    final ref = context.ref;
    final (themeMode, colorMode) = ref.watch(settingsProvider.select((settings) => (settings.theme, settings.colorMode)));
    final dynamicColors = ref.watch(dynamicColorsProvider);
    return TrayWatcher(
      child: WindowWatcher(
        child: LifeCycleWatcher(
          onChangedState: (AppLifecycleState state) {
            switch (state) {
              case AppLifecycleState.resumed:
                ref.redux(localIpProvider).dispatch(InitLocalIpAction());
                break;
              case AppLifecycleState.detached:
                // The main isolate is only exited when all child isolates are exited.
                // https://github.com/localsend/localsend/issues/1568
                ref.redux(parentIsolateProvider).dispatch(IsolateDisposeAction());
                break;
              default:
                break;
            }
          },
          child: ShortcutWatcher(
            child: MaterialApp(
              title: t.appName,
              locale: TranslationProvider.of(context).flutterLocale,
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              debugShowCheckedModeBanner: false,
              theme: getTheme(colorMode, Brightness.light, dynamicColors),
              darkTheme: getTheme(colorMode, Brightness.dark, dynamicColors),
              themeMode: colorMode == ColorMode.oled ? ThemeMode.dark : themeMode,
              navigatorKey: Routerino.navigatorKey,
              home: RouterinoHome(
                builder: () => const HomePage(
                  initialTab: HomeTab.devices,
                  appStart: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
