import 'dart:typed_data';

import 'package:computational_graph/computational_graph.dart';
import 'package:flutter/widgets.dart';

class NodeUiState {
  /// A set of RenderBox to update when node is dragged.
  Set<RenderBox> updateOnDrag = {};

  /// For allowing setState from [UiNodeMixin].
  /// The widget displaying this node should forward this to its own setState
  Function(Function())? onSetState;
}

/// A node that contains gui attributes
mixin UiNodeMixin on Node {
  static const keyX = 'ui_x';
  static const keyY = 'ui_y';

  /// UI state for this node. This should only be used by the node display
  final uiState = NodeUiState();

  double x = 0.0;
  double y = 0.0;

  /// Override this to set a min width for the node
  double get minWidth => 0.0;

  static Map<String, Uint8List> createAttributeFrom({double? x, double? y}) {
    return {
      keyX: (ByteData(8)..setFloat64(0, x ?? 0)).buffer.asUint8List(),
      keyY: (ByteData(8)..setFloat64(0, y ?? 0)).buffer.asUint8List(),
    };
  }

  /// Create attribute map for ui attributes. Classes using this mixin should
  /// call this and combine it with their own attributes.
  Map<String, Uint8List> getUiAttributes() {
    return createAttributeFrom(x: x, y: y);
  }

  @override
  Map<String, Uint8List> getAttributes() {
    return getUiAttributes();
  }

  /// Load ui attributes from an attribute map. Should be called in factories
  void loadAttributesFrom(Map<String, Uint8List>? attributes) {
    if (attributes == null) return;

    if (attributes.containsKey(keyX)) {
      x = ByteData.view(attributes[keyX]!.buffer).getFloat64(0);
    }

    if (attributes.containsKey(keyY)) {
      y = ByteData.view(attributes[keyY]!.buffer).getFloat64(0);
    }
  }

  /// Override this to build a ui widget for this node. It will be shown below
  /// the ports.
  Widget? buildUiWidget(BuildContext context) {
    return null;
  }

  @protected
  setState(Function() action) {
    if (uiState.onSetState != null) {
      uiState.onSetState?.call(action);
    } else {
      action();
    }
  }
}
