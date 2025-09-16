import 'package:flutter/material.dart';

/// Web平台的WindowWatcher实现，不执行任何操作
class WindowWatcher extends StatelessWidget {
  final Widget child;

  const WindowWatcher({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Web平台不支持窗口管理，直接返回子组件
    return child;
  }

  /// Web平台空实现
  static Future<void> closeWindow(BuildContext context) async {
    // Web平台不需要处理窗口关闭
    return;
  }
}