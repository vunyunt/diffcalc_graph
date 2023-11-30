import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/data/aggregates/hit_object_aggregate.dart';
import 'package:diffcalc_graph/data/indexed.dart';
import 'package:diffcalc_graph/grpc/gen/taiko.pb.dart';
import 'package:diffcalc_graph/nodes/ui_node.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class HitObjectAggregateVisualizer extends Node with UiNodeMixin {
  late final InPort<Indexed<int, HitObjectAggregate>,
      HitObjectAggregateVisualizer> input;

  late final OutPort<Indexed<int, HitObjectAggregate>,
      HitObjectAggregateVisualizer> forward;

  Stream<Indexed<int, HitObjectAggregate>>? _inStream;
  Stream<List<HitObjectAggregate>>? _transformedInStream;

  HitObjectAggregateVisualizer(super.graph, {super.id});

  @override
  double get minWidth => 420;

  @override
  Iterable<InPort<dynamic, Node>> createInPorts() {
    input = InPort(
        node: this,
        name: 'Input',
        onDataStreamAvailable: (stream) {
          _inStream = stream.asBroadcastStream();
          setState(() {
            _transformedInStream = _inStream?.transform(ScanStreamTransformer(
                (accumulated, value, index) => accumulated..add(value.value),
                []));
          });
          _inStream?.forEach((aggregate) {
            sendTo(forward, aggregate);
          });
        });

    return [input];
  }

  @override
  Iterable<OutPort<dynamic, Node>> createOutPorts() {
    forward = OutPort(
      node: this,
      name: 'Forward',
    );

    return [forward];
  }

  @override
  String get typeName => "HitObjectAggregateVisualizer";

  @override
  Widget? buildUiWidget(BuildContext context) {
    return _HitObjectAggregateDisplay<HitObjectAggregate>(
        input: _transformedInStream);
  }
}

class _HitObjectAggregateDisplay<AggregateType extends HitObjectAggregate>
    extends StatefulWidget {
  final Stream<List<AggregateType>>? input;

  const _HitObjectAggregateDisplay({super.key, this.input});

  @override
  State<StatefulWidget> createState() {
    return _HitObjectAggregateDisplayState<AggregateType>();
  }
}

class _HitObjectAggregateDisplayState<AggregateType extends HitObjectAggregate>
    extends State<_HitObjectAggregateDisplay<AggregateType>> {
  /// The display scale of intervals in pixels per millisecond.
  /// The default value of 0.2 means 2 pixel will represent 10 milliseconds
  double intervalScale = 0.2;

  @override
  void initState() {
    super.initState();
  }

  Widget buildAggregateDisplay(
      BuildContext context, List<HitObjectAggregate> aggregates, int index) {
    final aggregate = aggregates[index];
    final hitObjects = aggregate.allHitObjects.toList();

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, hitObjectIndex) {
        final hitObject = hitObjects[hitObjectIndex];
        return SizedBox(
          width: hitObjectIndex == 0
              ? 4
              : (hitObject.interval ?? 0) * intervalScale,
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(
                        style: BorderStyle.solid,
                        width: 4,
                        color: hitObject.hitObject.type == TaikoHitType.center
                            ? Colors.red
                            : Colors.blue))),
          ),
        );
      },
      itemCount: hitObjects.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AggregateType>>(
        initialData: const [],
        stream: widget.input,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }

          return SizedBox(
            height: 240,
            child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: SizedBox(
                        height: 12,
                        child: buildAggregateDisplay(
                            context, snapshot.data!, index),
                      ));
                }),
          );
        });
  }
}
