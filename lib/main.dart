import 'package:computational_graph/src/graph/graph.dart';
import 'package:diffcalc_graph/components/graph_display.dart';
import 'package:diffcalc_graph/data/aggregates/hit_object_aggregate.dart';
import 'package:diffcalc_graph/data/aggregates/timed_aggregate.dart';
import 'package:diffcalc_graph/data/indexed.dart';
import 'package:diffcalc_graph/data/taiko_difficulty_hit_object.dart';
import 'package:diffcalc_graph/data/timed.dart';
import 'package:diffcalc_graph/nodes/aggregators/flat_timing_aggregator.dart';
import 'package:diffcalc_graph/nodes/file_input_node.dart';
import 'package:diffcalc_graph/nodes/protobuf_beatmap_node.dart';
import 'package:diffcalc_graph/nodes/test_node.dart';
import 'package:diffcalc_graph/nodes/visualization/hit_object_aggregate_visualizer.dart';
import 'package:diffcalc_graph/ui_graph.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diffcalc Graph',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.dark(
            primaryContainer: Colors.grey[800],
            onPrimaryContainer: Colors.white,
            secondaryContainer: Colors.grey[900]),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final UiGraph _graph = UiGraph();
  late final FileInputNode fileInputNode;
  late final ProtobufBeatmapNode protobufBeatmapNode;
  late final FlatTimingAggregator hitObjectRhythmAggregator;
  late final HitObjectAggregateVisualizer hitObjectRhythmVisualizer;
  late final FlatTimingAggregator compositeRhythmAggregator;
  late final HitObjectAggregateVisualizer compositeVisualizer;

  _MyHomePageState() {
    fileInputNode = FileInputNode(_graph, id: "Beatmap File Input");
    protobufBeatmapNode =
        ProtobufBeatmapNode(_graph, id: "Protobuf Beatmap Decoder");
    hitObjectRhythmAggregator =
        FlatTimingAggregator(_graph, id: "First pass rhythm");
    hitObjectRhythmVisualizer = HitObjectAggregateVisualizer(_graph,
        id: "First pass rhythm visualizer");
    compositeRhythmAggregator =
        FlatTimingAggregator(_graph, id: "Second pass rhythm");
    compositeVisualizer = HitObjectAggregateVisualizer(_graph,
        id: "Second pass rhythm visualizer");

    // Edge.connect(fileInputNode.output, protobufBeatmapNode.inPort);
    // Edge.connect(protobufBeatmapNode.indexedHitObjectsOutput,
    //     hitObjectRhythmAggregator.input);
    // Edge.connect(
    //     hitObjectRhythmAggregator.output, hitObjectRhythmVisualizer.input);
    // Edge.connect(
    //     hitObjectRhythmAggregator.output, compositeRhythmAggregator.input);
    // Edge.connect(compositeRhythmAggregator.output, compositeVisualizer.input);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: GraphDisplay(graph: _graph),
      ),
    );
  }
}
