import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/data/aggregates/hit_object_aggregate.dart';
import 'package:diffcalc_graph/data/aggregates/timed_aggregate.dart';
import 'package:diffcalc_graph/data/indexed.dart';
import 'package:diffcalc_graph/data/taiko_difficulty_hit_object.dart';
import 'package:diffcalc_graph/data/timed.dart';
import 'package:diffcalc_graph/nodes/node_directory.dart';
import 'package:diffcalc_graph/nodes/ui_node.dart';
import 'package:rxdart/rxdart.dart';

class FlatTimingAggregator extends Node with UiNodeMixin {
  static const qualifiedName = "Aggregators.FlatTimingAggregator";

  @override
  String get typeName => qualifiedName;

  static void registerFactoryTo(NodeDirectory directory) {
    directory.registerFactoryFor(qualifiedName,
        (graph, {attributes, id}) => FlatTimingAggregator(graph, id: id)..loadAttributesFrom(
            attributes));
  }

  int marginOfError = 2;

  late final InPort<Indexed<int, Timed>, FlatTimingAggregator> input;

  late final OutPort<Indexed<int, HitObjectAggregate>, FlatTimingAggregator>
      output;

  FlatTimingAggregator(super.graph, {super.id});

  /// Check if [events] have intervals within marginOfError of each other.
  /// These [events] must be sorted by [startTime]
  bool _isFlat(List<Timed> events) {
    int averageInterval =
        ((events.last.startTime - events.first.startTime) / (events.length - 1))
            .round();

    return events.sublist(1).every((element) =>
        ((element.interval ?? 0) - averageInterval).abs() <= marginOfError);
  }

  @override
  void sendTo<DataType, NodeType extends Node>(
      OutPort<DataType, NodeType> port, DataType value) {
    super.sendTo(port, value);
  }

  HitObjectAggregate<Timed> createAggregate(
      dynamic exampleEvent, LinkedTimedAggregate<dynamic>? previous) {
    if (exampleEvent is TaikoDifficultyHitObject) {
      return FlatSimpleHitObjectAggregate(
          previous:
              previous as LinkedTimedAggregate<TaikoDifficultyHitObject>?);
    } else if (exampleEvent is HitObjectAggregate) {
      return FlatCompositeHitObjectAggregate(
          previous:
              previous as LinkedTimedAggregate<HitObjectAggregate<Timed>>?);
    } else {
      throw UnsupportedError(
          "FlatTimingAggregator currently only support HitObject-based events");
    }
  }

  @override
  Iterable<InPort<dynamic, Node>> createInPorts() {
    Indexed<int, HitObjectAggregate<Timed>>? currentAggregate;

    input = InPort(
        node: this,
        name: "input",
        onDataStreamAvailable: (events) {
          // Buffer events by 3. This is to allow access to "next" and "previous" events
          // In this case the middle event is considered the current event.
          events.bufferCount(3, 1).listen((indexedHitObjects) {
            // First event
            if (currentAggregate == null) {
              currentAggregate = Indexed(indexedHitObjects[0].index,
                  createAggregate(indexedHitObjects[0].value, null));

              currentAggregate!.value.elements.add(indexedHitObjects[0].value);
            }

            // Ignore last events
            if (indexedHitObjects.length < 3) {
              return;
            }

            if (currentAggregate!.value.elements.isEmpty ||
                _isFlat(indexedHitObjects.map((e) => e.value).toList())) {
              // If no timing change occurred, or the current aggregate is empty,
              // add current event to the current aggregate
              currentAggregate!.value.elements.add(indexedHitObjects[1].value);
            } else {
              // If a timing change has occurred, group the middle event to either
              // the previous or next aggregate, prioritizing shorter interval.
              final nextNote =
                  indexedHitObjects[indexedHitObjects.length - 1].value;
              final currentNote =
                  indexedHitObjects[indexedHitObjects.length - 2].value;
              if ((nextNote.interval ?? 0) > (currentNote.interval ?? 0)) {
                // Add the current event to the current aggregate
                currentAggregate!.value.elements
                    .add(indexedHitObjects[1].value);

                // Send the aggregate
                sendTo(output, currentAggregate!);

                // Create a new aggregate and pre-index it to the next event
                currentAggregate = Indexed(
                    indexedHitObjects[0].index,
                    createAggregate(
                        indexedHitObjects[0].value, currentAggregate?.value));
              } else {
                // Send the aggregate
                sendTo(output, currentAggregate!);

                // Create a new aggregate and index it to the current event
                currentAggregate = Indexed(
                    indexedHitObjects[1].index,
                    createAggregate(
                        indexedHitObjects[1].value, currentAggregate?.value));

                // Add the current event to the new aggregate
                currentAggregate!.value.elements
                    .add(indexedHitObjects[1].value);
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
}
