import 'dart:typed_data';

import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/grpc/gen/taiko.pb.dart';
import 'package:diffcalc_graph/nodes/ui_node.dart';

/// Reads a binary input as [TaikoBeatmap], and sends [TaikoHitObject]s through
/// [hitObjectsOutput]. Each [TaikoHitObject] will be send as a separate event
/// in the stream.
class ProtobufBeatmapNode extends Node with UiNodeMixin {
  late final InPort<Uint8List, ProtobufBeatmapNode> inPort;

  late final OutPort<TaikoHitObject, ProtobufBeatmapNode> hitObjectsOutput;

  ProtobufBeatmapNode(super.graph, {super.id});

  @override
  Iterable<InPort<dynamic, Node>> createInPorts() {
    inPort = InPort(
        node: this,
        name: 'Bytes Input',
        onDataStreamAvailable: (beatmapDataStream) {
          beatmapDataStream.forEach((bytes) async {
            final beatmap = TaikoBeatmap.fromBuffer(bytes);
            for (var element in beatmap.hitObjects) {
              sendTo(hitObjectsOutput, element);
            }
          });
        });

    return [inPort];
  }

  @override
  Iterable<OutPort<dynamic, Node>> createOutPorts() {
    hitObjectsOutput = OutPort(node: this, name: 'Hit Objects Output');

    return [hitObjectsOutput];
  }

  @override
  String get typeName => "ProtobufBeatmapNode";
}
