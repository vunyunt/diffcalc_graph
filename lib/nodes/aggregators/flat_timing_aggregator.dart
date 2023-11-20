import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/data/timed.dart';
import 'package:diffcalc_graph/nodes/ui_node.dart';

class FlatTimingAggregator<InputType extends Timed> extends Node
    with UiNodeMixin {
  int marginOfError = 2;

  late final InPort<InputType, FlatTimingAggregator> input;

  FlatTimingAggregator(super.graph, {super.id});

  @override
  Iterable<InPort<dynamic, Node>> createInPorts() {
    input = InPort(
        node: this,
        name: "input",
        onDataStreamAvailable: (events) {
          int? previousEventTime;

          events.forEach((event) {
            int? interval;

            if (previousEventTime != null) {
              interval = event.startTime - previousEventTime!;
            }

            previousEventTime = event.startTime;
          });
        });

    // TODO: implement createInPorts
    throw UnimplementedError();
  }

  @override
  Iterable<OutPort<dynamic, Node>> createOutPorts() {
    // TODO: implement createOutPorts
    throw UnimplementedError();
  }

  @override
  // TODO: implement typeName
  String get typeName => throw UnimplementedError();
}
