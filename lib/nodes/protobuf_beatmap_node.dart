import 'dart:typed_data';

import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/data/indexed.dart';
import 'package:diffcalc_graph/data/taiko_difficulty_hit_object.dart';
import 'package:diffcalc_graph/grpc/gen/taiko.pb.dart';
import 'package:diffcalc_graph/nodes/node_directory.dart';
import 'package:diffcalc_graph/nodes/ui_node.dart';

/// Reads a binary input as [TaikoBeatmap], and sends [TaikoHitObject]s through
/// [hitObjectsOutput]. Each [TaikoHitObject] will be send as a separate event
/// in the stream.
class ProtobufBeatmapNode extends Node with UiNodeMixin {
  static const qualifiedName = "ProtobufBeatmapNode";

  @override
  String get typeName => qualifiedName;

  static void registerFactoryTo(NodeDirectory directory) {
    directory.registerFactoryFor(
        qualifiedName,
        (graph, {attributes, id}) =>
            ProtobufBeatmapNode(graph, id: id)..loadAttributesFrom(attributes));
  }

  late final InPort<Uint8List, ProtobufBeatmapNode> inPort;

  late final OutPort<Indexed<int, TaikoDifficultyHitObject>,
      ProtobufBeatmapNode> indexedHitObjectsOutput;

  ProtobufBeatmapNode(super.graph, {super.id});

  @override
  Iterable<InPort<dynamic, Node>> createInPorts() {
    inPort = InPort(
        node: this,
        name: 'Bytes Input',
        onDataStreamAvailable: (beatmapDataStream) {
          beatmapDataStream.forEach((bytes) async {
            final beatmap = TaikoBeatmap.fromBuffer(bytes);
            TaikoDifficultyHitObject? previous;

            for (var element in beatmap.hitObjects) {
              TaikoDifficultyHitObject current =
                  TaikoDifficultyHitObject(element, previous: previous);
              previous = current;

              sendTo(indexedHitObjectsOutput,
                  Indexed(current.hitObject.index, current));
            }
          });
        });

    return [inPort];
  }

  @override
  Iterable<OutPort<dynamic, Node>> createOutPorts() {
    indexedHitObjectsOutput = OutPort(node: this, name: 'Indexed HitObjects');

    return [indexedHitObjectsOutput];
  }
}
