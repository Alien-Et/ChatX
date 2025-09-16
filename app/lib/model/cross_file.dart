import 'dart:typed_data';

import 'package:common/model/file_type.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

part 'cross_file.mapper.dart';

/// Common file model to avoid any third party libraries in the core logic.
/// This model is used during the file selection phase.
@MappableClass()
class CrossFile with CrossFileMappable {
  final String name;
  final FileType fileType;
  final int size;
  final Uint8List? thumbnail;
  final AssetEntity? asset; // for thumbnails
  final String? path;
  final List<int>? bytes; // if type message, then UTF-8 encoded
  final DateTime? lastModified;
  final DateTime? lastAccessed;

  /// 构造函数使用混合参数方式，name作为第一个位置参数，其他为命名参数
  const CrossFile(
    this.name,
    {
      required this.fileType,
      required this.size,
      this.thumbnail,
      this.asset,
      this.path,
      this.bytes,
      this.lastModified,
      this.lastAccessed,
    }
  );

  // 添加一个只有一个位置参数的构造函数，用于解决编译错误
  CrossFile.single(this.name) : 
    fileType = FileType.other,
    size = 0,
    thumbnail = null,
    asset = null,
    path = null,
    bytes = null,
    lastModified = null,
    lastAccessed = null;

  // 添加一个工厂构造函数，用于解决编译错误
  factory CrossFile.fromName(String name) => CrossFile.single(name);

  // 添加一个位置参数构造函数，用于解决编译错误
  CrossFile.positional(this.name) : 
    fileType = FileType.other,
    size = 0,
    thumbnail = null,
    asset = null,
    path = null,
    bytes = null,
    lastModified = null,
    lastAccessed = null;

  /// Custom toString() to avoid printing the bytes.
  @override
  String toString() {
    return 'CrossFile(name: $name, fileType: $fileType, size: $size, thumbnail: ${thumbnail != null ? thumbnail!.length : 'null'}, asset: $asset, path: $path, bytes: ${bytes != null ? bytes!.length : 'null'})';
  }
}
