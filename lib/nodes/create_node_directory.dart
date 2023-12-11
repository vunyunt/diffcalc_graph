import 'package:diffcalc_graph/nodes/aggregators/flat_timing_aggregator.dart';
import 'package:diffcalc_graph/nodes/evaluators/interval_ratio_evaluator.dart';
import 'package:diffcalc_graph/nodes/file_input_node.dart';
import 'package:diffcalc_graph/nodes/node_directory.dart';
import 'package:diffcalc_graph/nodes/protobuf_beatmap_node.dart';
import 'package:diffcalc_graph/nodes/visualizers/hit_object_aggregate_visualizer.dart';

void registerNodesTo(NodeDirectory directory) {
  FileInputNode.registerFactoryTo(directory);
  ProtobufBeatmapNode.registerFactoryTo(directory);
  HitObjectAggregateVisualizer.registerFactoryTo(directory);
  IntervalRatioEvaluator.registerFactoryTo(directory);
  FlatTimingAggregator.registerFactoryTo(directory);
}

NodeDirectory createNodeDirectory() {
  NodeDirectory directory = NodeDirectory();
  registerNodesTo(directory);
  return directory;
}
