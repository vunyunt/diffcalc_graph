import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/data/nodes/ui_node.dart';

/// Node for testing node display, should be removed
class TestNode extends Node with UiNodeMixin {
  TestNode(super.graph);

  @override
  String get typeName => "TypeName";

  @override
  Iterable<InPort> createInPorts() => [
        InPort<int, TestNode>(
            name: "inPort1",
            node: this,
            onDataStreamAvailable: (Stream<int> dataStream) {}),
        InPort<int, TestNode>(
            name: "inPort2",
            node: this,
            onDataStreamAvailable: (Stream<int> dataStream) {})
      ];

  @override
  Iterable<OutPort> createOutPorts() => [
        OutPort<int, TestNode>(name: "outPort1", node: this),
        OutPort<int, TestNode>(name: "outPort2", node: this),
        OutPort<int, TestNode>(name: "outPort3", node: this)
      ];
}
