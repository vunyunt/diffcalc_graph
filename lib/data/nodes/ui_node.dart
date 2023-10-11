import 'dart:typed_data';

import 'package:computational_graph/computational_graph.dart';
import 'package:flutter/cupertino.dart';

/// A node that contains gui attributes
mixin UiNodeMixin on Node {
  static const keyX = 'ui_x';
  static const keyY = 'ui_y';

  final Set<RenderBox> updateOnDrag = {};

  double x = 0.0;
  double y = 0.0;

  /// Create attribute map for ui attributes. Classes using this mixin should
  /// call this and combine it with their own attributes.
  Map<String, Uint8List> getUiAttributes() {
    return {
      keyX: (ByteData(8)..setFloat64(0, x)).buffer.asUint8List(),
      keyY: (ByteData(8)..setFloat64(0, y)).buffer.asUint8List(),
    };
  }

  /// Load ui attributes from an attribute map. Should be called in factories
  void loadAttributesFrom(Map<String, Uint8List> attributes) {
    x = ByteData.view(attributes[keyX]!.buffer).getFloat64(0);
    y = ByteData.view(attributes[keyY]!.buffer).getFloat64(0);
  }
}
