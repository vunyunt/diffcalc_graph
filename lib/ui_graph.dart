import 'dart:convert';
import 'dart:typed_data';

import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/nodes/ui_node.dart';

class UiGraph extends Graph<UiNodeMixin> {
  static const String attributeKeyTitle = "title";

  String title;

  UiGraph({this.title = "New graph"});

  void loadAttributes(Map<String, Uint8List>? attributes) {
    if (attributes == null) return;

    if (attributes.containsKey(attributeKeyTitle)) {
      title = (const Utf8Decoder()).convert(attributes[attributeKeyTitle]!);
    }
  }

  factory UiGraph.fromAttributes(Map<String, Uint8List>? attributes) {
    return UiGraph()..loadAttributes(attributes);
  }

  @override
  Map<String, Uint8List> getAttributes() {
    return {
      attributeKeyTitle:
          (const Utf8Encoder().convert(title)).buffer.asUint8List()
    };
  }
}
