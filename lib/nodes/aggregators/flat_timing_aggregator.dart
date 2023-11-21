import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/data/aggregates/timed_aggregate.dart';
import 'package:diffcalc_graph/data/timed.dart';
import 'package:diffcalc_graph/nodes/ui_node.dart';
import 'package:rxdart/rxdart.dart';

class FlatTimingAggregator<InputType extends Timed> extends Node
    with UiNodeMixin {
  int marginOfError = 2;

  late final InPort<InputType, FlatTimingAggregator> input;

  late final OutPort<LinkedFlatTimedAggregate<InputType>, FlatTimingAggregator>
      output;

  FlatTimingAggregator(super.graph, {super.id});

  /// Check if n events have intervals within marginOfError of each other
  /// Time points must be sorted
  bool _isFlat(List<InputType> events) {
    int averageInterval =
        ((events.last.startTime - events.first.startTime) / events.length)
            .round();

    return events.sublist(1).every((element) =>
        (element.interval ?? 0 - averageInterval).abs() <= marginOfError);
  }

  @override
  Iterable<InPort<dynamic, Node>> createInPorts() {
    LinkedFlatTimedAggregate<InputType>? currentAggregate;

    input = InPort(
        node: this,
        name: "input",
        onDataStreamAvailable: (events) {
          events.bufferCount(3, 1).listen((hitObjects) {
            // First note
            if (currentAggregate == null) {
              currentAggregate = LinkedFlatTimedAggregate<InputType>();
              currentAggregate!.elements.add(hitObjects[0]);
            }

            // Ignore last notes
            if (hitObjects.length < 3) {
              return;
            }

            if (_isFlat(hitObjects)) {
              currentAggregate!.elements.add(hitObjects[1]);
            } else {
              // If a timing change has occurred, group the middle note to either
              // the previous or next aggregate, prioritizing shorter interval.
              if ((hitObjects[0].interval ?? 0) >
                  (hitObjects[1].interval ?? 0)) {
                currentAggregate!.elements.add(hitObjects[1]);
                sendTo(output, currentAggregate!);
                currentAggregate = LinkedFlatTimedAggregate<InputType>();
              } else {
                sendTo(output, currentAggregate!);
                currentAggregate = LinkedFlatTimedAggregate<InputType>();
                currentAggregate!.elements.add(hitObjects[1]);
              }
            }
          });
        });

    return [input];
  }

  @override
  Iterable<OutPort<dynamic, Node>> createOutPorts() {
    output = OutPort(
      node: this,
      name: "output",
    );

    return [output];
  }

  @override
  String get typeName => "FlatTimingAggregator";
}
