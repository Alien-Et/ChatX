import 'package:flutter/material.dart';

/// Web平台的TrayWatcher实现，不执行任何操作
class TrayWatcher extends StatelessWidget {
  final Widget child;

  const TrayWatcher({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    // Web平台不支持系统托盘，直接返回子组件
    return child;
  }
}